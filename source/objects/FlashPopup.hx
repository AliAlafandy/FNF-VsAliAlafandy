package objects;

import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

import shaders.flixel.system.FlxShader;
import shaders.ColorShader;

class FlashPopup extends FlxSpriteGroup
{
	public var onFinish:Void->Void = null;

	var alphaTween:FlxTween;
	var flash:FlxSprite;
	var popupBG:FlxSprite;
	var flashTxt:FlxText;
	var lerpScore:Int = 0;
	var canLerp:Bool = false;

	var sinat:Int = 270;
	var sinatTxt:Int = 190;

	public function new(amount:Int, ?camera:FlxCamera = null)
	{
		super(x, y);
		this.y -= 100;
		lerpScore = amount;

		ClientPrefs.flashes += amount;

		var colorShader:ColorShader = new ColorShader(0);

		ClientPrefs.saveSettings();
		popupBG = new FlxSprite(300, 0).makeGraphic(300, 100, 0xF80000FF); // FlxG.width - 300
		popupBG.visible = false;
		popupBG.scrollFactor.set();
		add(popupBG);

		flash = new FlxSprite(0, 0).loadGraphic(Paths.image('flash'));
		flash.setPosition(popupBG.getGraphicMidpoint().x - sinat, popupBG.getGraphicMidpoint().y - (flash.height / 2));
		flash.antialiasing = true;
		flash.updateHitbox();
		flash.scrollFactor.set();
		flash.scale.set(0.3, 0.3);
		add(flash);

		flashTxt = new FlxText(0, 0, 200, Std.string(amount), 35);
		flashTxt.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		flashTxt.setPosition(popupBG.getGraphicMidpoint().x - sinatTxt, popupBG.getGraphicMidpoint().y - (flashTxt.height / 2));
		flashTxt.updateHitbox();
		flashTxt.borderSize = 3;
		flashTxt.scrollFactor.set();
		flashTxt.antialiasing = true;
		add(flashTxt);

		flash.shader = colorShader.shader;
		flashTxt.shader = colorShader.shader;

		FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});

		new FlxTimer().start(0.9, function(tmr:FlxTimer)
		{
			canLerp = true;
			colorShader.amount = 1;
			FlxTween.tween(colorShader, {amount: 0}, 0.8, {ease: FlxEase.expoOut});
			FlxG.sound.play(Paths.sound('getflash'), 0.9);
		});

		var cam:Array<FlxCamera> = FlxG.cameras.list;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		flash.cameras = cam;
		flashTxt.cameras = cam;
		popupBG.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if(canLerp) {
			lerpScore = Math.floor(FlxMath.lerp(lerpScore, 0, boundTo(elapsed * 4, 0, 1) / 1.5));
			if(Math.abs(0 - lerpScore) < 10) lerpScore = 0;
		}

		flashTxt.text = Std.string(lerpScore);
		flash.setPosition(popupBG.getGraphicMidpoint().x - sinat, popupBG.getGraphicMidpoint().y - (flash.height / 2));
		flashTxt.setPosition(popupBG.getGraphicMidpoint().x - sinatTxt, popupBG.getGraphicMidpoint().y - (flashTxt.height / 2));
	}

	override function destroy()
	{
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}

private function boundTo(value:Float, min:Float, max:Float):Float
{
	var newValue:Float = value;

	if(newValue < min)
		newValue = min;
	else if(newValue > max)
		newValue = max;

	return newValue;
}
