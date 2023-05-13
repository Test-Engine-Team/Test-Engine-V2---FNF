package;

import openfl.Assets;
import haxe.Json;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
using StringTools;

typedef StageJsonShit =
{
	var image:String;
	var animName:String;
	var anim:String;
	var x:Float;
	var y:Float;
	var scrollY:Float;
	var scrollX:Float;
}
typedef StageLoadingShit =
{
	var objects:Array<StageJsonShit>;
	var camZoom:Float;
	var halloween:Bool;
}

class BGhandler extends FlxTypedGroup<FlxBasic>
{
	public var zoom:Float;

	public function new(name:String)
	{
		super();

		var realstage:StageLoadingShit = Json.parse(Assets.getText('assets/stages/$name.json'));

		zoom = realstage.camZoom;

		for (sprites in realstage.objects){
			if (sprites.anim == null && sprites.animName == null){
				var object = new FlxSprite(sprites.x, sprites.y).loadGraphic(Paths.image(sprites.image));
				object.scrollFactor.set(sprites.scrollX, sprites.scrollY);
				add(object);
			}
			else if (sprites.anim != null && sprites.animName != null){
				var animShit = Paths.getSparrowAtlas(sprites.image);

				var object = new FlxSprite(sprites.x, sprites.y);
				object.frames = animShit;
				object.animation.addByPrefix(sprites.animName, sprites.anim);
				object.animation.play(sprites.animName, true);
				add(object);
			}
		}
	}
}
