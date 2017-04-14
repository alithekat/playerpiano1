//Author: Alison Curcio
//Date: April 12, 2017

//MIDI Player Piano 1
//now on GitHub!

//set up MIDI out
MidiOut mout;
MidiMsg msgOut;
1 => int portOut;

//set up MIDI in
MidiIn min;
MidiMsg msgIn;
0 => int portIn;

//MIDI port error checks
if (!min.open(portIn))
{
    <<<"Error: MIDI in port did not open on port: ", portIn>>>;
    me.exit();
}
if (!mout.open(portOut))
{
    <<<"Error: MIDI out port did not open on port: ", portOut>>>;
    me.exit();
} 

//set pulse
.2::second => dur pulse;

//map midi notes to scale degrees (c major, starting at middle c)
fun int mapToScale (int midiNote)
{
    if (midiNote == 60) 
    {
        return 1;
    }
    else if (midiNote == 62)
    {
        return 2;    
    }
    else if (midiNote == 64)
    {
        return 3;    
    }
    else if (midiNote == 65)
    {
        return 4;    
    }
    else if (midiNote == 67)
    {
        return 5;    
    }
    else if (midiNote == 69)
    {
        return 6;    
    }
    else if (midiNote == 71)
    {
        return 7;    
    }
    else 
    {
        return 0;
    }
}

//map scale degrees to midi notes (c major, starting at middle c)
fun int mapToMidi (int scaleDegree)
{
    if ((scaleDegree == 1) | (scaleDegree == 8 ))
    {
        return 60;
    }
    else if ((scaleDegree == 2) | (scaleDegree == 9 ))
    {
        return 62;    
    }
    else if ((scaleDegree == 3) | (scaleDegree == 10 ))
    {
        return 64;    
    }
    else if ((scaleDegree == 4) | (scaleDegree == 11 ))
    {
        return 65;    
    }
    else if ((scaleDegree == 5) | (scaleDegree == 12 ))
    {
        return 67;    
    }
    else if ((scaleDegree == 6) | (scaleDegree == 13 ))
    {
        return 69;    
    }
    else if ((scaleDegree == 7) | (scaleDegree == 14 ))
    {
        return 71;    
    }
    else 
    {
        return 0;
    }
}

//improvisation array (number of scale degrees above the root)
[0, 0, 2, 2, 2, 4, 4, 4, 3, 5, 6 ] @=> int interval[];

fun void playNotes (int scaleDegree, int note, int volume)
{
    while(true)
    {
        Math.random2(0, (interval.cap()-1)) => int i;
        (interval[i] + scaleDegree) => int newNote;
        mapToMidi(newNote) => msgOut.data2;
        (volume - 10) => msgOut.data3;
        144 => msgOut.data1;
        mout.send(msgOut);
        pulse*(Math.random2(1,6)) => now;
    }
}

Shred shreds[0];

//MAIN PROGRAM
while(true)
{
    min => now;
    while (min.recv(msgIn))
    {
        //print out all data received
        <<<msgIn.data1, msgIn.data2, msgIn.data3 >>>;
        
        if (msgIn.data1 == 144 && msgIn.data3 >0)
        {
            //map midi note name to scale degree
            mapToScale(msgIn.data2) => int scaleDegree;
            <<<"scale degree = ", scaleDegree>>>;
            //map midi note to a string (to identify the child shred)
            msgIn.data2 + "" => string midiNoteString;
            spork ~ playNotes (scaleDegree, msgIn.data2, msgIn.data3) @=> shreds[midiNoteString] ; 
        }
        else if (msgIn.data1 == 144 && msgIn.data3 == 0)
        {
            <<<"note released">>>;
            //map midi note to a string (to identify the child shred)
            msgIn.data2 + "" => string midiNoteString;
            if(shreds[midiNoteString] != null)
            {
                Machine.remove(shreds[midiNoteString].id());
                null @=> shreds[midiNoteString];
            }
        }
        else
        {
            continue;
        }
    }
    pulse => now;
}
