package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;

using StringTools;

class DevMessage extends MusicBeatState {
    override function create(){
        var message = new FlxText(0, 50, FlxG.width, "", 16);
        message.text = "
        I wish I could've done more for this engine.\nI've done and put so much work and effort but it was still a buggy and broken mess atm.
        \nI really tried my hardest to fix as many as I could, but when Yeeeter came around, I thought he wouldn't be so much trouble.\nOh how wrong I was,
        \nwhen me and him fell into a relationship (he started it first btw), I thought I would have someone to truly love,\n until I soon realized after we broke up
        \nhe was just doing this so he could cope with him not being able to date PennyPancake.\nI realize now with all the stuff Mackery and Brandon have showed...
        \nIt made me realize how crazy and mentally unstable he was, he really shouldn't be running test engine in this state he's in.
        \nThis team and engine has honestly been crumbling as of lately, it's sad since Megalo has no control over the whole situation.
        \nAnd as much as I loved working on the engine and with the team, sometimes good things come to an end...
        \nThis is my statement and way of saying goodbye to this engine and team.
        \nI quit test engine, since I knew I lost, and he won. Rest in piece to whatever the dream test engine was.
        \nAnd that anyone who tries to revive the legacy of this engine, rots.\nI'm sorry Mackery, Brandon and Megalo. -MemeHoovy
        \nPS: No this isn't a fucking suicide note, even if I made it seem like one, and sorry for that vid I sent in the old server.
        \nI already left it.
        ";
        message.screenCenter(X);
        message.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        message.alignment = CENTER;
        add(message);

        super.create();
    }

    override function update(elapsed:Float){
        if (controls.BACK){
            FlxG.switchState(new MainMenuState());
        }
        super.update(elapsed);
    }
}