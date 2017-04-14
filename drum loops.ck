//Author: Alison Curcio
//Date: April 14, 2017

//Three drum loops

//SET UP SOUND FILES
    Gain master => dac;
    SndBuf kick => master;
    SndBuf click => master;
    SndBuf hihat => master;
    SndBuf snare => master;
    SndBuf cowbell => master;

    //set master volume
    0.6 => float master_vol;
    master_vol => master.gain;

    //set relative volumes
    .6 => click.gain;
    .8 => snare.gain;
    .8 => kick.gain;
    .2 => hihat.gain;
    1 => cowbell.gain;

    //set playback rates (i.e. pitch)
    1.3 => cowbell.rate;

    //set file paths for audio samples and set playheads to end of sound so no initial playback
    me.dir(-1) + "/audio samples/click_01.wav" => click.read;
    click.samples() => click.pos;
    me.dir(-1) + "/audio samples/kick_01.wav" => kick.read;
    kick.samples() => kick.pos;
    me.dir(-1) + "/audio samples/snare_03.wav" => snare.read;
    snare.samples() => snare.pos;
    me.dir(-1) + "/audio samples/hihat_04.wav" => hihat.read;
    hihat.samples() => hihat.pos;
    me.dir(-1) + "/audio samples/cowbell_01.wav" => cowbell.read;
    cowbell.samples() => cowbell.pos;
    
    
//SET UP MIDI IN
    MidiIn min;
    MidiMsg msgIn;
    0 => int portIn;

    //MIDI port error checks
    if (!min.open(portIn))
    {
        <<<"Error: MIDI in port did not open on port: ", portIn>>>;
        me.exit();
    }

//GLOBAL VARIABLES
    //set pulse
    .2::second => dur pulse;
    
    //set arrays for instrument patterns
    [1,0,1,1] @=> int clickBeat[];
    [1,0,1,0] @=> int hihatBeat[];
    [1,0,0,1,1,0,0,1] @=> int kickPattern1[];
    [1,0,1,0,1,0,1,0] @=> int snarePattern1[];
    [0,0,0,0,0,0,0,0] @=> int cowbellPattern1[];
    [0,0,0,0,0,0,0,0] @=> int kickPattern2[];
    [0,0,0,0,0,0,0,0] @=> int snarePattern2[];
    [1,1,1,1,1,1,1,1] @=> int cowbellPattern2[];
    [0,0,0,0,0,0,0,0] @=> int kickPattern3[];
    [0,0,0,0,0,0,0,0] @=> int snarePattern3[];
    [0,0,0,0,0,0,0,0] @=> int cowbellPattern3[];
    
    //set array to make loop
    [kickPattern1, snarePattern1, cowbellPattern1] @=> int loop1[][];
    [kickPattern2, snarePattern2, cowbellPattern2] @=> int loop2[][];    
    [kickPattern3, snarePattern3, cowbellPattern3] @=> int loop3[][];
    
    //array of loops
    [loop1, loop2, loop3] @=> int pickLoop[][][];
    
        
    //map Roland pedals to loop numbers
    fun int mapToLoop (int pedalNumber)
    {
        if (pedalNumber == 64) 
        {
            return 0;
        }
        else if (pedalNumber == 66)
        {
            return 1;    
        }
        else if (pedalNumber == 67)
        {
            return 2;    
        }
    }

    
//DEFINE FUNCTIONS
    //Function clickHatBeat: subdivided quarter note beat with clicks and hihats
    fun void clickHatBeat ( )
    {
        for ( 0 => int i; i<4; i++ )
        {
            if ( clickBeat[i] == 1 )
            {
                0 => click.pos;
                Math.random2f(.6, 1.4) => click.rate;
            }
            if ( hihatBeat[i] == 1 )
            {
                0 => hihat.pos;
                Math.random2f(1.5, 1.8) => hihat.rate;
            }
            pulse => now;
        }
    }
    
    //Function kickSnareBell: 8-beat kick and snare and cowbell pattern
    fun void kickSnareBell ( int beatCounter, int loopNumber )
    {
        if ( pickLoop[loopNumber][0][beatCounter] == 1 )
        {
            0 => kick.pos;
        }
        if ( pickLoop[loopNumber][1][beatCounter] == 1 )
        {
            0 => snare.pos;
        }
        if ( pickLoop[loopNumber][2][beatCounter] == 1 )
        {
            0 => cowbell.pos;
        }
    }

    //function to play loops
    fun void playLoop(int loopNumber)
    {
        for ( 0 => int i; i < 8; i++ )
        {
            kickSnareBell(i, loopNumber);   
            clickHatBeat();
        }
    }


//MAIN PROGRAM
while(true)
{
    min => now;
    while (min.recv(msgIn))
    {
        //print out all data received
        <<<msgIn.data1, msgIn.data2, msgIn.data3 >>>;
        
        if (msgIn.data1 == 176 && msgIn.data3 == 127)
        {
            <<<"pedal down">>>;
            //map pedal to loop number
            mapToLoop(msgIn.data2) => int loopNumber;
            playLoop(loopNumber);
            
        }
        else if (msgIn.data1 == 176 && msgIn.data3 == 0)
        {
            <<<"pedal released">>>;
            continue;
        }
        else
        {
            continue;
        }
    }
}

