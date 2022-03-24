/*
 WHAT IS THIS? A SOUND QUEUE MANAGER TO SAVE EDICT
 HOW DO I USE THIS? 
 create 1 point_template ( name it whatever you like ) & ambient generic ( name it whatever you like )
 put the ambient generic inside the template you create and attach this script to the point template

 HOW TO PLAYSOUND?
 1. Put your sound data to ::SOUND_DATA, keep the data structur followed (I have put an example)
 2. either do 
    ::PlaySound(SOUND_DATA.sound_key), remember the 1st arg is MUST BE an **INSTANCE** OF sounds class
    ::PlaySound(sounds("targetname", "path")) <- it'll set the rest keyvalue to default
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
*/

::QUEUE_SOUND <- false;
::G_SOUND <- self;
::MUSIC_PLAYING <- null;

::SOUND_QUEUE <- [] // QUEUE A SOUND
::SOUND_TEMP <- {} // CONTROL AN ALREADY PLAYED SOUND

::SOUND_SETTINGS <- {
    flags = {
        defaults = 48,
        everywhere = 49,
        silent = 16,
        loops = 32
    }
    type = {
        music = "music",
        effect = "effect",
    }
}

function OnPostSpawn() {
    self.ValidateScriptScope();
    local sc = self.GetScriptScope()
    sc.sound <- null;
}

//========== EXAMPLE =============================================
function TestSound() {
    for (local i=0; i < 10; i++) {
        PlaySound(SOUND_DATA.test, Vector(RandomInt(-2048,2048), RandomInt(-2048,2048), RandomInt(-2048,2048)), SOUND_SETTINGS.flags.defaults, null, null, null)
    }
}
function TestSound2() {
    ::PlaySound(sounds("random", "#survival/missile_land_06.wav"))
    ::PlaySound(sounds("random", "#survival/missile_land_06.wav", caller.GetOrigin()))
}
function TestSound3() {
    local snd = sounds("random", "#survival/missile_land_06.wav")
    snd.health = 1
    ::PlaySound(snd)
}
//=================================================================

// AUTO QUEUE A SOUND IF RUN ON 1 TICK
function StartQueue() {
    if(!QUEUE_SOUND)return;
    EntFireByHandle(self, "RunScriptCode", "StartQueue();", FrameTime(), self, null)
    if(SOUND_QUEUE.len()==0){QUEUE_SOUND=false;return;}
    self.ValidateScriptScope();
    local sc = self.GetScriptScope()
    sc.sound <- SOUND_QUEUE[0];
    EntFireByHandle(G_SOUND, "ForceSpawn", "", 0, G_SOUND, caller)
}

::sounds <- class{
    sound_name = null;
    path = null;
    origin = null;
    flag = null;
    health = null;
    radius = null;
    handle = null;
    type = null;
    duration = null;
    autokill = null;
    constructor(s_name, s_path, 
    v_origin = Vector(0, 0, 0), 
    i_flag = SOUND_SETTINGS.flags.defaults, 
    f_health = 10, 
    f_radius = 1250, 
    s_type = SOUND_SETTINGS.type.effect, 
    f_duration = 0,
    b_autokill = false
    ){
        sound_name = s_name;
        path = s_path;
        origin = v_origin;
        flag = i_flag;
        health = f_health;
        radius = f_radius;
        type = s_type;
        duration = f_duration;
        autokill = b_autokill;
    }

    function Stop(_stop=true, _kill=false, _instantly=false) {
        if(!this.handle.IsValid()){printl("Invalid Handle for: "+this.sound_name);return}
        if(!_stop && !_kill){
            EntFireByHandle(this.handle, "Volume", "0", (!_instantly)?this.duration:0, this.handle, null);
            EntFireByHandle(this.handle, "kill", "", (!_instantly)?this.duration:0+0.02, this.handle, null);
            // EntFireByHandle(G_SOUND, "RunScriptCode", "delete SOUND_TEMP."+this.sound_name, (!_instantly)?this.duration:0, G_SOUND, null)
            if(this.sound_name in SOUND_TEMP)delete SOUND_TEMP[this.sound_name]
            return;
        }
        if(_stop)EntFireByHandle(this.handle, "Volume", "0", (!_instantly)?this.duration:0, this.handle, null);
        if(_kill){
            EntFireByHandle(this.handle, "kill", "", (!_instantly)?this.duration:0+0.02, this.handle, null);
            // EntFireByHandle(G_SOUND, "RunScriptCode", "delete SOUND_TEMP."+this.sound_name, (!_instantly)?this.duration:0, G_SOUND, null)
            if(this.sound_name in SOUND_TEMP)delete SOUND_TEMP[this.sound_name]
        }
    }

    function Play() {
        if(!this.handle.IsValid()){printl("Invalid Handle for: "+this.sound_name);return}
        EntFireByHandle(this.handle, "PlaySound", "0", 0, this.handle, null)
    }

    function __SetKeyValue(_key, _value) {
        if(!this.handle.IsValid()){printl("Invalid Handle for: "+this.sound_name);return}
        switch( typeof _value )
        {
            case "bool":
            case "integer":
                return this.handle.__KeyValueFromInt( _key, val.tointeger() );

            case "float":
                return this.handle.__KeyValueFromFloat( _key, _value );

            case "string":
                return this.handle.__KeyValueFromString( _key, _value );

            case "Vector":
                return this.handle.__KeyValueFromVector( _key, _value );

            case "null":
                return true;

            default:
                throw "Invalid input type: " + typeof _value;
        }
    }

    function DumpData() {
        printl("______________________________");
		printl("name: " + this.sound_name)
        printl("path: " + this.path)
        printl("origin: " + this.origin)
        printl("flag: " + this.flag)
        printl("health: " + this.health)
        printl("radius: " + this.radius)
        printl("handle: " + this.handle)
        printl("type: " + this.type)
        printl("duration: " + this.duration)
        printl("auto kill: " + this.autokill)
    }
}
// PLACE YOUR SOUND DATA HERE
::SOUND_DATA <- {
    sound_key = sounds(
        "sound_name",                                // Sound targetname so you can always control them ingame
        "Your Sound Path",                           // Sound path to where the sound is
        Vector(0,0,0),                               // Sound origin where this sound will play
        SOUND_SETTINGS.flags.everywhere,             // Spawnflags of the sound, see ::SOUND_SETTINGS to refer the flags
        10,                                          // Sound start volume
        1250,                                        // Sound radius
        SOUND_SETTINGS.type.music,                   // Sound type, if its music type it'll check whether you wanna auto kill or kill on another music play, if effect it'll be auto killed whenever they spawn
        69                                           // Sound duration, the duration to Stop/Kill this sound
        true                                         // Set true to auto kill after its play
    ),
    test = sounds(
        "test_sound"
        "#survival/missile_land_06.wav",
        Vector(0, 0, 0),
        SOUND_SETTINGS.flags.everywhere,
        10,
        1250,
        SOUND_SETTINGS.type.effect
    ),
    tracing = sounds(
        "tracing"
        "music/1x/tracing_instru.mp3",
        Vector(0, 0, 0),
        SOUND_SETTINGS.flags.everywhere,
        10,
        1250,
        SOUND_SETTINGS.type.music, 
        5,
        true
    )
}

::PlaySound <- function(_sound = null, _origin = null, _flag = null, _health = null, _radius = null, _type = null, _duration = null, _autokill = null) {
    if (_sound==null || typeof _sound != "instance")throw "Invalid sound data!";
    local _uname = UniqueString()
    SOUND_QUEUE.push(sounds(
    _sound.sound_name+_uname, 
    _sound.path, 
    (_origin != null)?_origin:_sound.origin, 
    (_flag != null)?_flag:_sound.flag, 
    (_health != null)?_health:_sound.health, 
    (_radius != null)?_radius:_sound.radius, 
    (_type != null)?_type:_sound.type,
    (_duration != null)?_duration:_sound.duration,
    (_autokill != null)?_autokill:_sound.autokill
    ))
    if(!QUEUE_SOUND){QUEUE_SOUND=true;EntFireByHandle(G_SOUND, "RunScriptCode", "StartQueue();", FrameTime(), G_SOUND, caller);}
}

function PreSpawnInstance( _ClassName, _TargetName)
{
    self.ValidateScriptScope()
    local sc = self.GetScriptScope();
    local _sound = sc.sound
    local keyval = {
        targetname = _sound.sound_name,
        message = _sound.path,
        origin = _sound.origin,
        spawnflags = _sound.flag,
        health = _sound.health,
        radius = _sound.radius
    }
    return keyval
}

function PostSpawn(_Ents) {
    self.ValidateScriptScope()
    local sc = self.GetScriptScope();
    local _sound = sc.sound
    foreach (_name, _handle in _Ents) {
        if(_sound.type == SOUND_SETTINGS.type.music && MUSIC_PLAYING!=null){        // kill other music playing
            MUSIC_PLAYING.Stop(true, true, true)
        }
        EntFireByHandle(_handle, "PlaySound", "", 0, _handle, null)
        if(SOUND_QUEUE[0].sound_name == _sound.sound_name)SOUND_QUEUE[0].handle = _handle;
        SOUND_TEMP[_sound.sound_name] <- SOUND_QUEUE[0]
        if(_sound.type == SOUND_SETTINGS.type.music)MUSIC_PLAYING <- SOUND_QUEUE[0];
        SOUND_QUEUE.remove(0)
        if(_sound.duration == 0 && !(_sound.type == SOUND_SETTINGS.type.music)){_sound.Stop(false, true);return} // if its has 0 duration and its not a music type, kill them, to save edict
        if(_sound.autokill)_sound.Stop(true, true)    // check whether it'll killed automatically after it start or not
    }
}