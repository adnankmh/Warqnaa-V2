import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'app_sounds.dart';

/// Lazily initialized device speech. No microphone, recordings or player data.
class PhraseSpeechR292 {
  PhraseSpeechR292._();
  static FlutterTts? _engine;
  static bool _busy=false;

  static Future<bool> play(String phrase,String language) async {
    if(!AppSounds.enabled||_busy||phrase.trim().isEmpty||
        !const ['ar','en'].contains(language))return false;
    _busy=true;
    try{
      final engine=_engine??=FlutterTts();
      final tags=language=='ar'?const ['ar','ar-SA','ar-EG']:const ['en-US','en-GB','en'];
      String? available;
      for(final tag in tags){
        final result=await engine.isLanguageAvailable(tag).timeout(const Duration(seconds:3));
        if(result==true||result==1){available=tag;break;}
      }
      if(available==null||!AppSounds.enabled)return false;
      await engine.stop().timeout(const Duration(seconds:3));
      final selected=await engine.setLanguage(available).timeout(const Duration(seconds:3));
      if(selected==0||selected==false)return false;
      final volume=(AppSounds.volume*(AppSounds.channelVolumes[SoundChannel.reactions]??1.0)).clamp(0.0,1.0).toDouble();
      await engine.setVolume(volume).timeout(const Duration(seconds:3));
      await engine.setSpeechRate(.48).timeout(const Duration(seconds:3));
      if(!AppSounds.enabled||volume==0)return false;
      // Waiting for the utterance prevents concurrent requests from overlapping.
      await engine.awaitSpeakCompletion(true).timeout(const Duration(seconds:3));
      if(!AppSounds.enabled)return false;
      final result=await engine.speak(phrase).timeout(const Duration(seconds:15));
      return result==1||result==true;
    }catch(_){
      try{await _engine?.stop().timeout(const Duration(seconds:2));}catch(_){}
      return false;
    }finally{_busy=false;}
  }
}
