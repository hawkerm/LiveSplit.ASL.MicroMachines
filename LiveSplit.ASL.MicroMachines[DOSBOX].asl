// For Micro Machines 100% - MICRO.EXE 28,955 bytes - DOSBox v0.74
// By: Mikeware http://github.com/hawkerm/LiveSplit.ASL.MicroMachines

state("DOSBOX")
{
    // Needed for Splits
    byte HighlightedPlayer : 0x193A1A0, 0xAF40;
    byte RaceCounterInitial : 0x193A1A0, 0xB0F0;
    string11 RaceMapFilename : 0x193A1A0, 0xBF80;
    byte PlayerNotInControl : 0x193A1A0, 0xC08E;
    byte LapCounter : 0x193A1A0, 0xC0CD;
    byte PlayerPosition : 0x193A1A0, 0xC0CF;
    byte RaceCounterReal : 0x193A1A0, 0xD6A1;
    byte InRace : 0x193A1A0, 0x15C6A;

    byte RuffTruxMap : 0x193A1A0, 0xB122;
    
    // Needed for Map Viewing
    byte PlayerPositionOnCourse : 0x193A1A0, 0xC0C1;
    byte PlayerYMapQuadrant : 0x193A1A0, 0xC0D4;
    byte PlayerXMapQuadrant : 0x193A1A0, 0xC0D6;
    byte BluePositionOnCourse : 0x193A1A0, 0xC225;
    byte BlueLapCounter : 0x193A1A0, 0xC231;
    byte GreenPositionOnCourse : 0x193A1A0, 0xC389;
    byte GreenLapCounter : 0x193A1A0, 0xC395;
    byte YellowPositionOnCourse : 0x193A1A0, 0xC4ED;
    byte YellowLapCounter : 0x193A1A0, 0xC4F9;
}

start
{
    //Qualifying Starts
    if (current.RaceCounterReal == 0 && old.PlayerNotInControl == 0x0A && current.PlayerNotInControl == 0x0)
    {
        vars.PlayerFalls = 0; // Reset when Start
        vars.RuffTruxWon = 0;
    }
    return current.RaceCounterReal == 0 && old.PlayerNotInControl == 0x0A && current.PlayerNotInControl == 0x0;
}

split
{
    return 
        (current.RaceCounterReal == 0 && current.LapCounter == 2 && old.LapCounter == 3) || // Qualifying Race Finishes
        (old.HighlightedPlayer != 0x47 && current.HighlightedPlayer == 0x47) || // Player Selected Cherry
        (old.HighlightedPlayer != 0x46 && current.HighlightedPlayer == 0x46) || // Player Selected Jethro
        (old.HighlightedPlayer != 0x45 && current.HighlightedPlayer == 0x45) || // Player Selected Dwayne
        (old.HighlightedPlayer != 0x44 && current.HighlightedPlayer == 0x44) || // Player Selected Joel
        (old.HighlightedPlayer != 0x43 && current.HighlightedPlayer == 0x43) || // Player Selected Chen
        (old.HighlightedPlayer != 0x42 && current.HighlightedPlayer == 0x42) || // Player Selected Anne
        (old.HighlightedPlayer != 0x41 && current.HighlightedPlayer == 0x41) || // Player Selected Mike
        (old.HighlightedPlayer != 0x40 && current.HighlightedPlayer == 0x40) || // Player Selected Walter
        (current.RaceCounterReal != 0 && old.PlayerNotInControl == 0x0A && current.PlayerNotInControl == 0x0) || // Any Race Starts
        (current.RaceCounterReal != 0 && old.LapCounter == 1 && current.LapCounter == 0) || // Any Other Race Finishes
        (current.RaceMapFilename.StartsWith("ROUND9") && old.LapCounter == 3 && current.LapCounter == 2) || // RuffTrux Race Lap Complete
        (current.RaceMapFilename.StartsWith("ROUND9") && old.PlayerNotInControl != 0x10 && current.PlayerNotInControl == 0x10); // RuffTrux Race Lap Failed
}

isLoading
{
    // Determine GameTime vs. RealTime
    return
        (current.LapCounter == 0) || // Game in-between Races (most cases after Breakfast Bends)
        (current.PlayerNotInControl == 0x0A) || // Race in Pre-Start State
        (current.PlayerNotInControl == 0x0F || current.PlayerNotInControl == 0x10) || // End of RuffTrux Trial
        (current.RaceMapFilename.StartsWith("ROUND9") && current.LapCounter != 3) || // RuffTrux Race Lap Complete Before 0x0F
        (current.RaceCounterReal == 0 && current.LapCounter == 2) || // Leaving Player Select after Qualifying Race
        (current.RaceCounterReal == 1 && current.InRace == 0x70) || // Accounts for transition to Breakfast Bends from Qualifying Race
        (!current.RaceMapFilename.StartsWith("ROUND2") && !current.RaceMapFilename.StartsWith("ROUND8") && current.InRace == 0x70); // Game in-between Races after Qualifying except for Boats and Choppers
}

init
{
    vars.PlayerFalls = 0;
    vars.ClosestPlayer = "";
    vars.PlayerPos = 0;
    vars.BluePos = 0;
    vars.GreenPos = 0;
    vars.YellowPos = 0;
    vars.RuffTruxWon = 0;
    print("MAP: " + current.RaceMapFilename);
}

update
{
    // Player is now being placed back on track
    if (old.PlayerNotInControl != 2 && current.PlayerNotInControl == 2)
    {
        vars.PlayerFalls++;
    }
    
    // RuffTrux Race Lap Complete
    if (current.RaceMapFilename.StartsWith("ROUND9") && old.LapCounter == 3 && current.LapCounter == 2)
    {
        vars.RuffTruxWon++;
    }
    
    // Calculate Next Closest Player Ahead or Behind
    vars.PlayerPos = (4 - current.LapCounter) * 1000 + current.PlayerPositionOnCourse;
    vars.BluePos = (4 - current.BlueLapCounter) * 1000 + current.BluePositionOnCourse;
    vars.GreenPos = (4 - current.GreenLapCounter) * 1000 + current.GreenPositionOnCourse;
    vars.YellowPos = (4 - current.YellowLapCounter) * 1000 + current.YellowPositionOnCourse;
    
    int[] pos = new int[4] { vars.PlayerPos, vars.BluePos, vars.GreenPos, vars.YellowPos};
    
    Array.Sort(pos);
    
    // If we're in lead, get closest behind us
    if (vars.PlayerPos > vars.BluePos && vars.PlayerPos > vars.GreenPos && vars.PlayerPos > vars.YellowPos)
    {
        vars.ClosestPlayer = pos[2];
    }
    // If we're not, get the next ahead of us
    else
    {
        vars.ClosestPlayer = pos[Array.IndexOf(pos, vars.PlayerPos)+1];
    }
}
