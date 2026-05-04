import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_type/core/constants/app_constants.dart';
import 'package:zero_type/features/prompt/domain/repositories/prompt_repository.dart';

class PromptRepositoryImpl implements PromptRepository {
  PromptRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  Future<File> _getCustomFile(String fileName) async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<String> _loadDefaultFromAsset(String assetPath, String fallback) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      return content.trim();
    } catch (e) {
      print('[PromptRepo] ERROR loading $assetPath: $e');
      return fallback;
    }
  }

  Future<String> _readCustomOrDefault(
      String customFileName, Future<String> Function() defaultLoader) async {
    try {
      final file = await _getCustomFile(customFileName);
      if (await file.exists()) {
        final content = (await file.readAsString()).trim();
        if (content.isNotEmpty) return content;
      }
    } catch (e) {
      print('[PromptRepo] Error reading $customFileName: $e');
    }
    return await defaultLoader();
  }

  Future<String> _saveCustom(
      String customFileName, String prefsKey, String prompt) async {
    final cleaned = prompt.trim();
    try {
      final file = await _getCustomFile(customFileName);
      await file.writeAsString(cleaned, flush: true);
    } catch (e) {
      print('[PromptRepo] Error saving $customFileName: $e');
    }
    await _prefs.setString(prefsKey, cleaned);
    return cleaned;
  }

  Future<String> _resetCustom(String customFileName, String prefsKey,
      Future<String> Function() defaultLoader) async {
    try {
      final file = await _getCustomFile(customFileName);
      if (await file.exists()) await file.delete();
    } catch (e) {
      print('[PromptRepo] Error deleting $customFileName: $e');
    }
    await _prefs.remove(prefsKey);
    return await defaultLoader();
  }

  // ── Speech ────────────────────────────────────────────────────────────────

  @override
  Future<String> getDefaultSpeechPrompt() => _loadDefaultFromAsset(
        'prompts/SpeechToText.prompt',
        '請將語音精確轉換成繁體中文，並依語意加上適當的標點符號。',
      );

  @override
  Future<String> getSpeechPrompt() =>
      _readCustomOrDefault('SpeechToText_Custom.prompt', getDefaultSpeechPrompt);

  @override
  Future<String> saveSpeechPrompt(String prompt) => _saveCustom(
        'SpeechToText_Custom.prompt',
        AppConstants.speechPromptKey,
        prompt,
      );

  @override
  Future<String> resetSpeechPrompt() => _resetCustom(
        'SpeechToText_Custom.prompt',
        AppConstants.speechPromptKey,
        getDefaultSpeechPrompt,
      );

  // ── Refinement ────────────────────────────────────────────────────────────

  @override
  Future<String> getDefaultRefinementPrompt() => _loadDefaultFromAsset(
        'prompts/TextRefinement.prompt',
        '優化以下語音轉錄文字：移除「嗯/啊/那個」等填充詞、修正口誤、加上適當標點，'
            '保留原意，僅輸出優化後的純文字。',
      );

  @override
  Future<String> getRefinementPrompt() => _readCustomOrDefault(
        'TextRefinement_Custom.prompt',
        getDefaultRefinementPrompt,
      );

  @override
  Future<String> saveRefinementPrompt(String prompt) => _saveCustom(
        'TextRefinement_Custom.prompt',
        AppConstants.refinementPromptKey,
        prompt,
      );

  @override
  Future<String> resetRefinementPrompt() => _resetCustom(
        'TextRefinement_Custom.prompt',
        AppConstants.refinementPromptKey,
        getDefaultRefinementPrompt,
      );
}
