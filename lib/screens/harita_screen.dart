import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models.dart';
import '../data/ziyaret_data.dart';
import '../theme/app_theme.dart';

class HaritaScreen extends StatefulWidget {
  const HaritaScreen({super.key});
  @override
  State<HaritaScreen> createState() => _HaritaScreenState();
}

class _HaritaScreenState extends State<HaritaScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  @override
  void initState() { super.initState(); tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita • Offline Destekli'),
        bottom: TabBar(
          controller: tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.gold,
          tabs: const [Tab(icon: Icon(Icons.mosque_rounded, size: 18), text: 'Mekke'), Tab(icon: Icon(Icons.mosque_outlined, size: 18), text: 'Medine')],
        ),
      ),
      body: TabBarView(
        controller: tab,
        children: const [
          _GercekHarita(sehir: 'Mekke'),
          _GercekHarita(sehir: 'Medine'),
        ],
      ),
    );
  }
}

class _GercekHarita extends StatefulWidget {
  final String sehir;
  const _GercekHarita({required this.sehir});
  @override
  State<_GercekHarita> createState() => _GercekHaritaState();
}

class _GercekHaritaState extends State<_GercekHarita> {
  final MapController _mapController = MapController();
  ZiyaretYeri? selected;
  bool _tileError = false;
  LatLng? userLocation;
  bool locating = false;

  LatLng get _center => widget.sehir == 'Mekke' ? const LatLng(21.3891, 39.8579) : const LatLng(24.4672, 39.6111);
  double get _zoom => widget.sehir == 'Mekke' ? 13.5 : 13.0;
  List<ZiyaretYeri> get _yerler => ziyaretYerleri.where((z) => z.sehir == widget.sehir).toList();

  Future<void> _konumAl() async {
    setState(() => locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum servisi kapalı')));
        setState(() => locating = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni reddedildi')));
          setState(() => locating = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni kalıcı reddedildi, ayarlardan açın')));
        setState(() => locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => userLocation = loc);
      _mapController.move(loc, 15);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum alınamadı: $e')));
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> _yolTarifi(ZiyaretYeri yer) async {
    // Yandex Maps/Navigasyon ile yol tarifi
    final yandexUrl = Uri.parse('https://yandex.com.tr/maps/?rtext=~${yer.lat},${yer.lng}');
    if (await canLaunchUrl(yandexUrl)) {
      await launchUrl(yandexUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${yer.ad} • ${yer.lat}, ${yer.lng}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: _tileError ? Colors.red.shade50 : AppTheme.goldLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: _tileError ? Colors.red.shade200 : AppTheme.gold.withValues(alpha: 0.3))),
          child: Row(
            children: [
              Icon(_tileError ? Icons.cloud_off_rounded : Icons.satellite_alt_rounded, size: 16, color: _tileError ? Colors.red.shade700 : AppTheme.goldDark),
              const SizedBox(width: 6),
              Expanded(child: Text(_tileError ? 'Offline mod: Harita önbellekten yükleniyor' : 'Gerçek harita • Yakınlaştır, kaydır, noktaya dokun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _tileError ? Colors.red.shade700 : AppTheme.goldDark))),
              if (_tileError)
                TextButton(onPressed: () => setState(() => _tileError = false), child: const Text('Yenile', style: TextStyle(fontSize: 11)))
              else
                const Icon(Icons.verified_rounded, size: 14, color: AppTheme.goldDark),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _zoom,
                    minZoom: 10,
                    maxZoom: 18,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    onTap: (_, _) => setState(() => selected = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hacumre.hac_umre_rehberi',
                      maxZoom: 19,
                      errorTileCallback: (tile, error, stack) {
                        if (!_tileError && mounted) setState(() => _tileError = true);
                      },
                    ),
                    if (_yerler.isNotEmpty)
                      MarkerLayer(
                        markers: [
                          for (final yer in _yerler)
                            Marker(
                              point: LatLng(yer.lat, yer.lng),
                              width: 110,
                              height: 70,
                              child: GestureDetector(
                                onTap: () => setState(() => selected = yer),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: selected?.id == yer.id ? AppTheme.primary : (yer.sehir == 'Mekke' ? AppTheme.primary : AppTheme.goldDark),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
                                      ),
                                      child: Icon(yer.icon, color: Colors.white, size: 16),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)]),
                                      child: Text(yer.ad, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (userLocation != null)
                            Marker(
                              point: userLocation!,
                              width: 40,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 8)]),
                                child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
                      ),
                    RichAttributionWidget(
                      attributions: [TextSourceAttribution('© OpenStreetMap', onTap: () async => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')))],
                    ),
                  ],
                ),
                Positioned(
                  right: 10,
                  bottom: 90,
                  child: Column(
                    children: [
                      FloatingActionButton.small(heroTag: 'zoom_in_${widget.sehir}', backgroundColor: Colors.white, foregroundColor: AppTheme.primary, onPressed: () => _mapController.move(_mapController.camera.center, (_mapController.camera.zoom + 1).clamp(10, 18)), child: const Icon(Icons.add_rounded)),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(heroTag: 'zoom_out_${widget.sehir}', backgroundColor: Colors.white, foregroundColor: AppTheme.primary, onPressed: () => _mapController.move(_mapController.camera.center, (_mapController.camera.zoom - 1).clamp(10, 18)), child: const Icon(Icons.remove_rounded)),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(heroTag: 'center_${widget.sehir}', backgroundColor: AppTheme.primary, foregroundColor: Colors.white, onPressed: () => _mapController.move(_center, _zoom), child: const Icon(Icons.center_focus_strong_rounded)),
                    ],
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 20,
                  child: FloatingActionButton.extended(
                    heroTag: 'loc_${widget.sehir}',
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    icon: locating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(locating ? 'Alınıyor...' : 'Konumum', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: locating ? null : _konumAl,
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)]),
                    child: Text(widget.sehir == 'Mekke' ? 'Mekke • ${_yerler.length} yer' : 'Medine • ${_yerler.length} yer', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selected != null)
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)]),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Icon(selected!.icon, color: AppTheme.primary, size: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(selected!.ad, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text('${selected!.kategori} • ${selected!.lat.toStringAsFixed(4)}, ${selected!.lng.toStringAsFixed(4)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ]),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: const Text('Git', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _yolTarifi(selected!),
                ),
                const SizedBox(width: 6),
                IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => setState(() => selected = null)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(
            children: [
              _Legend(color: AppTheme.primary, label: 'Mekke'),
              const SizedBox(width: 12),
              _Legend(color: AppTheme.goldDark, label: 'Medine'),
              const SizedBox(width: 12),
              _Legend(color: Colors.blue, label: 'Konumunuz'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 11))]);
}
