// Copyright (C) 2024 Rudson Alves
// 
// This file is part of trainers_stopwatch.
// 
// trainers_stopwatch is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// trainers_stopwatch is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with trainers_stopwatch.  If not, see <https://www.gnu.org/licenses/>.

import '../../common/models/settings_model.dart';
import '../../store/stores/settings_store.dart';
import 'abstract_settings_repository.dart';

class SettingsRepository implements AbstractSettingsRepositoy {
  final _store = SettingsStore();

  @override
  Future<int> insert(SettingsModel settings) async {
    final id = await _store.insert(settings.toMap());
    settings.id = id;

    return id;
  }

  @override
  Future<SettingsModel?> query() async {
    final map = await _store.query();
    if (map == null) return null;
    final settings = SettingsModel.fromMap(map);
    return settings;
  }

  @override
  Future<int> update(SettingsModel settings) async {
    final result = await _store.update(settings.toMap());
    return result;
  }
}
