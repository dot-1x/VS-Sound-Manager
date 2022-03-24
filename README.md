# VS-Sound-Manager
 WHAT IS THIS? A SOUND QUEUE MANAGER TO SAVE EDICT  
 **HOW DO I USE THIS?**  
 create 1 point_template ( name it whatever you like ) & ambient generic ( name it whatever you like )  
 put the ambient generic inside the template you create and attach this script to the point template  

 **HOW TO PLAYSOUND?**
 1. Put your sound data to `::SOUND_DATA`
 2. either do  
    `::PlaySound(SOUND_DATA.sound_key)`, remember the 1st arg is **MUST BE** an ***INSTANCE*** OF sounds class  
    `::PlaySound(sounds("targetname", "path"))` <- it'll set the rest keyvalue to default  
    or `OnOutput an_entity,RunScriptCode,PlaySound(SOUND_DATA.key),0,1`  
 for further, see example  
 3. all done  
 sounds structure
 ```
    targetname,                                 (Sound targetname so you can always control them ingame, MUST SET)
    path,                                       (Sound path to where the sound is, MUST SET)
    origin = Vector(0, 0, 0);                   (Sound origin where this sound will play)
    flag = SOUND_SETTINGS.flags.everywhere;     (Spawnflags of the sound, see ::SOUND_SETTINGS to refer the flags)
    health = 10;                                (Sound start volume)
    radius = 1250;                              (Sound radius)
    type = SOUND_SETTINGS.type.effect;          (Sound type, if its music type it'll check whether you wanna auto kill or kill on another music play, if effect it'll be auto killed whenever they spawn)
    duration = 0;                               (Sound duration, the duration to Stop/Kill this sound)
    autokill = false;                           (Set true to auto kill after its play)
```
