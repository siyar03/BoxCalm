import 'package:flutter/foundation.dart';

import '../core/constants/presets.dart';
import '../models/preset.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

class PresetsProvider extends ChangeNotifier {
  PresetsProvider({
    required StorageService storage,
    required SettingsProvider settings,
  })  : _storage = storage,
        _settings = settings {
    _builtIns = builtInPresets();
    _custom = storage.loadCustomPresets();
    _favoriteIds = storage.loadFavoriteIds();
    _applyFavorites();
    final last = _settings.lastPresetId;
    _selected = byId(last) ?? all.first;
  }

  final StorageService _storage;
  final SettingsProvider _settings;

  late List<Preset> _builtIns;
  late List<Preset> _custom;
  late Set<String> _favoriteIds;
  late Preset _selected;

  List<Preset> get builtIns => List.unmodifiable(_builtIns);
  List<Preset> get custom => List.unmodifiable(_custom);
  List<Preset> get all => [..._builtIns, ..._custom];
  Preset get selected => _selected;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<Preset> get favorites =>
      all.where((p) => _favoriteIds.contains(p.id)).toList();

  Preset? byId(String? id) {
    if (id == null) return null;
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  void _applyFavorites() {
    for (var i = 0; i < _builtIns.length; i++) {
      _builtIns[i] = _builtIns[i]
          .copyWith(isFavorite: _favoriteIds.contains(_builtIns[i].id));
    }
    for (var i = 0; i < _custom.length; i++) {
      _custom[i] = _custom[i]
          .copyWith(isFavorite: _favoriteIds.contains(_custom[i].id));
    }
  }

  Future<void> select(Preset preset) async {
    _selected = preset;
    notifyListeners();
    await _settings.setLastPreset(preset.id);
  }

  Future<void> toggleFavorite(Preset preset) async {
    if (_favoriteIds.contains(preset.id)) {
      _favoriteIds.remove(preset.id);
    } else {
      _favoriteIds.add(preset.id);
    }
    _replace(preset.copyWith(isFavorite: _favoriteIds.contains(preset.id)));
    notifyListeners();
    await _storage.saveFavoriteIds(_favoriteIds);
  }

  void _replace(Preset updated) {
    for (var i = 0; i < _builtIns.length; i++) {
      if (_builtIns[i].id == updated.id) {
        _builtIns[i] = updated;
        if (_selected.id == updated.id) _selected = updated;
        return;
      }
    }
    for (var i = 0; i < _custom.length; i++) {
      if (_custom[i].id == updated.id) {
        _custom[i] = updated;
        if (_selected.id == updated.id) _selected = updated;
        return;
      }
    }
  }

  Future<Preset> save(Preset preset) async {
    final isNew = !_custom.any((p) => p.id == preset.id);
    final withFavorite = preset.copyWith(
      isFavorite: _favoriteIds.contains(preset.id),
      sortOrder: isNew ? _custom.length : preset.sortOrder,
    );
    if (isNew) {
      _custom.add(withFavorite);
    } else {
      final index = _custom.indexWhere((p) => p.id == preset.id);
      if (index >= 0) _custom[index] = withFavorite;
    }
    _custom.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _selected = withFavorite;
    notifyListeners();
    await _storage.savePreset(withFavorite);
    await _settings.setLastPreset(withFavorite.id);
    return withFavorite;
  }

  Future<Preset> duplicate(Preset preset) async {
    final copy = preset.copyWith(
      id: nextPresetId(),
      name: '${preset.name} copy',
      isBuiltIn: false,
      isFavorite: false,
      category: PresetCategory.custom,
      sortOrder: _custom.length,
      clearCycles: false,
    );
    return save(copy);
  }

  Future<void> delete(Preset preset) async {
    if (preset.isBuiltIn) return;
    _custom.removeWhere((p) => p.id == preset.id);
    _favoriteIds.remove(preset.id);
    if (_selected.id == preset.id) {
      _selected = _builtIns.first;
      await _settings.setLastPreset(_selected.id);
    }
    notifyListeners();
    await _storage.deletePreset(preset.id);
    await _storage.saveFavoriteIds(_favoriteIds);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _custom.length) return;
    final item = _custom.removeAt(oldIndex);
    final target = newIndex.clamp(0, _custom.length);
    _custom.insert(target, item);
    for (var i = 0; i < _custom.length; i++) {
      _custom[i] = _custom[i].copyWith(sortOrder: i);
      await _storage.savePreset(_custom[i]);
    }
    notifyListeners();
  }
}
