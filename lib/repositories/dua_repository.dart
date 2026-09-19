import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_error.dart';
import '../core/result.dart';
import '../services/dua_api_service.dart';
import '../services/adapters/dua_adapter.dart';
import '../services/adapters/ummah_adapter.dart';
import '../services/adapters/masnun_adapter.dart';
import '../services/adapters/hisn_adapter.dart';

class DuaRepository {
  final DuaAdapter ummah;
  final DuaAdapter masnun;
  final DuaAdapter hisn;
  static const _cacheKey = 'dua_api_cache_v2';
  static const _cacheTimeKey = 'dua_api_cache_time';

  DuaRepository({
    DuaAdapter? ummahAdapter,
    DuaAdapter? masnunAdapter,
    DuaAdapter? hisnAdapter,
  })  : ummah = ummahAdapter ?? UmmahAdapter(),
        masnun = masnunAdapter ?? MasnunAdapter(),
        hisn = hisnAdapter ?? HisnAdapter();

  Future<Result<List<ApiDua>>> getDuas({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await loadCache();
      if (cached.isNotEmpty) {
        // Arka planda yenile, ama önbelleği döndür
        unawaited(_refreshInBackground());
        return Success(cached);
      }
    }
    try {
      final fresh = await _fetchFresh();
      await _saveCache(fresh);
      return Success(fresh);
    } on AppError catch (e) {
      final cached = await loadCache();
      if (cached.isNotEmpty) return Success(cached);
      return Failure(e);
    } catch (e) {
      final cached = await loadCache();
      if (cached.isNotEmpty) return Success(cached);
      return Failure(AppError(e.toString()));
    }
  }

  Future<List<ApiDua>> _fetchFresh() async {
    List<ApiDua> ummahList = [];
    try {
      ummahList = await ummah.fetchAll().timeout(const Duration(seconds: 20));
    } catch (e) {
      throw AppError.network('Ummah: $e');
    }
    // Türkçe zenginleştirme — Arapça normalize eşleşme
    try {
      final masnunList = await (masnun as MasnunAdapter).fetchWithLimit(100).timeout(const Duration(seconds: 20));
      final byArabic = <String, ApiDua>{};
      for (final m in masnunList) {
        if (m.arabic.isEmpty || m.translationTr.isEmpty) continue;
        byArabic.putIfAbsent(normalizeArabic(m.arabic), () => m);
      }
      ummahList = ummahList.map((u) {
        if (u.translationTr.isNotEmpty) return u;
        final m = u.arabic.isEmpty ? null : byArabic[normalizeArabic(u.arabic)];
        if (m == null) return u;
        return ApiDua(
          id: u.id,
          category: u.category,
          title: u.title,
          titleTr: m.title,
          arabic: u.arabic,
          transliteration: u.transliteration,
          translation: u.translation,
          translationTr: m.translationTr,
          source: u.source,
          audioUrl: u.audioUrl ?? m.audioUrl,
          repeat: u.repeat,
        );
      }).toList();
    } catch (e) {
      debugPrint('Masnun merge: $e');
    }
    if (ummahList.isNotEmpty) return ummahList;
    try {
      final hisnList = await hisn.fetchAll();
      if (hisnList.isNotEmpty) return hisnList;
    } catch (e) {
      throw AppError.network('Hisn: $e');
    }
    throw AppError.network('Hiçbir kaynaktan dua alınamadı');
  }

  Future<void> _refreshInBackground() async {
    try {
      final fresh = await _fetchFresh();
      await _saveCache(fresh);
    } catch (_) {}
  }

  Future<void> _saveCache(List<ApiDua> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_cacheKey, jsonEncode(list.map((e) => e.toJson()).toList()));
    await p.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<ApiDua>> loadCache() async {
    final p = await SharedPreferences.getInstance();
    final str = p.getString(_cacheKey);
    if (str == null) return [];
    try {
      final List decoded = jsonDecode(str) as List;
      return decoded.map((e) => ApiDua.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return await ummah.fetchCategories();
    } catch (_) {
      return ['hajj', 'morning', 'evening', 'travel', 'food', 'sleep', 'forgiveness', 'protection', 'dhikr', 'after_prayer'];
    }
  }
}
