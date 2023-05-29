package;

import PlayState;
import Controls;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
#if desktop
import Discord.DiscordClient;
#end

//create a results screen displaying how good the user did
class ResultsState extends MusicBeatState
{
    public static var songName:String;
    public static var difficulty:String;
    public static var isStoryMode:Bool = false;
    public static var weekNum:Int;
    public static var accuracy:Float;
    public static var score:Int;
    public static var misses:Int;
    public static var notesHit:Int;
    public static var highestCombo:Int;
    public static var rank:String;

    override function create() {
        #if desktop
        DiscordClient.changePresence("Viewing the Results", songName + " (" + difficulty + ")");
        #end

        var menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        menuBG.color = 0x302D2D;
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.scrollFactor.set(0, 0);
        add(menuBG);

        var songNameTxt = new FlxText(0, 40, FlxG.width);
        if (!isStoryMode)
            songNameTxt.text = songName + " (" + difficulty + ")";
        else
            songNameTxt.text = "Week " + weekNum;
        songNameTxt.setFormat(Paths.font("vcr.ttf"), 16, 0xFF000000, "left");
        songNameTxt.alpha = 0.8;
        add(songNameTxt);

        var title = new FlxText(0, 0, FlxG.width, "Results");
        title.setFormat(Paths.font("vcr.ttf"), 64, 0xFF000000, "center");
        title.y = 50;
        add(title);

        var rankTxt = new FlxText(0, 0, FlxG.width, "Your Rank: " + rank);
        rankTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        rankTxt.y = 120;
        add(rankTxt);

        var accuracyTxt = new FlxText(0, 0, FlxG.width, "Accuracy: " + accuracy + "%");
        accuracyTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        accuracyTxt.y = rankTxt.y + 40;
        add(accuracyTxt);

        var scoreTxt = new FlxText(0, 0, FlxG.width, "Score: " + score);
        scoreTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        scoreTxt.y = accuracyTxt.y + 40;
        add(scoreTxt);

        var missTxt = new FlxText(0, 0, FlxG.width, "Misses: " + misses);
        missTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFF000000, "center");
        missTxt.y = scoreTxt.y + 40;
        add(missTxt);

        var leaveTxt = new FlxText(0, 0, FlxG.width, "Press ACCEPT to leave");
        leaveTxt.setFormat(Paths.font("vcr.ttf"), 16, 0xFF000000, "center");
        leaveTxt.alpha = 0.8;
        leaveTxt.y = missTxt.y + 80;
        add(leaveTxt);
    }

    override public function update(elapsed:Float)
    {
        if (controls.ACCEPT) {
            if (isStoryMode) {
                FlxG.switchState(new StoryMenuState());
            } else {
                FlxG.switchState(new FreeplayState());
                trace("WENT BACK TO FREEPLAY??");
            }
        }
    }
}