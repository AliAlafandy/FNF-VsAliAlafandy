package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

import flixel.math.FlxMath;
import flixel.text.FlxText;

import sys.io.File;
import haxe.Json;

class GalleryState extends MusicBeatState
{
	var itemGroup:FlxTypedGroup<GalleryImage>;
	var uiGroup:FlxSpriteGroup;

	var galleryStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	
	var galleryText:FlxText;
	var descText:FlxText;
	
	var topBG:FlxSprite;
	var bottomBG:FlxSprite;

	var currentIndex:Int = 0;
	var allowInputs:Bool = true;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		bg.color = 0xFF000080;
		// bg.updateHitbox();

		if (ClientPrefs.data.lowQuality == false)
		{
			var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x330000FF, 0x0));
			grid.velocity.set(40, 40);
			grid.scrollFactor.set(0, 0);
			grid.alpha = 0;
			FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			add(grid);
		}

		itemGroup = new FlxTypedGroup<GalleryImage>();
		uiGroup = new FlxSpriteGroup();

		add(itemGroup);
		add(uiGroup);

		var defaultList:Array<Array<String>> = [ // Name - Sprite name - Description -- Link
			['Sprite Sheet', 'spriteSheets', 'Drawn by Ali Alafandy, Learning Animation (Sad Moment).'], // https://www.youtube.com/@alialafandy
			['M.Shaban', 'mShaban', 'Just a Cool Guy with Green Hair.'], // https://www.youtube.com/@2025_توكلت_علي_لله
			['Ahmed Zezo', 'ahmedZezo', 'Just a Cool Guy with Mix Hair.'], // https://www.youtube.com/@ahmedzezopro
			['Ahmed Hamedo', 'ahmedHamedo', 'Just a Cool Guy with Light Blue Hair.'], // https://www.roblox.com/users/5515913481/profile
			['Ahmed Alafandy', 'ahmedAlafandy', 'Just a Cool Guy with Black Hair.'], // https://www.youtube.com/@ahmedalafandy3060
			['AliOX', 'aliOX', 'Blue Fox from Smiling Critters.'] // https://www.youtube.com/@alialafandyarabic
		];

		for(i in defaultList)
		{
			galleryStuff.push(i);
		}

		for (i in 0...galleryStuff.length)
		{
			var imagePath:String = "gallery/";

			var newItem = new GalleryImage();
			newItem.loadGraphic(Paths.image(imagePath + galleryStuff[i][1]));
			// newItem.screenCenter();
			newItem.ID = i;
			itemGroup.add(newItem);
		}

		topBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 66, 0xFF000000); // FlxG.height - 6
		uiGroup.add(topBG);

		bottomBG = new FlxSprite(0, FlxG.height - 66).makeGraphic(FlxG.width, 66, 0xFF000000);
		uiGroup.add(bottomBG);

		galleryText = new FlxText(50, -100, FlxG.width - 100, "");
		galleryText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLUE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		galleryText.screenCenter();
		galleryText.y -= 275;
		uiGroup.add(galleryText);

		descText = new FlxText(50, -100, FlxG.width - 100, "");
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLUE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter();
		descText.y += 275;
		uiGroup.add(descText);

		changeSelection();

		#if mobile
		addTouchPad("LEFT_RIGHT", "B"); // A_B
		#end

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_LEFT_P && allowInputs)
		{
			changeSelection(-1);
			FlxG.sound.play(Paths.sound("scrollMenu"));
		}

		if (controls.UI_RIGHT_P && allowInputs)
		{
			changeSelection(1);
			FlxG.sound.play(Paths.sound("scrollMenu"));
		}

		if (controls.BACK && allowInputs)
		{
			allowInputs = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		/*if (controls.ACCEPT && allowInputs)
		{
			CoolUtil.browserLoad(galleryStuff[i][3]);
		}*/
	}

	function changeSelection(i:Int = 0)
	{
		currentIndex = FlxMath.wrap(currentIndex + i, 0, galleryStuff.length - 1);

		galleryText.text = galleryStuff[currentIndex][0];
		descText.text = galleryStuff[currentIndex][2];

		var change = 0;

		for (item in itemGroup) {
			item.posX = change++ - currentIndex;
			item.alpha = (item.ID == currentIndex) ? 1 : 0.6;
		}
	}
}

class GalleryImage extends FlxSprite
{
	public var lerpSpeed:Float = 6;
	public var posX:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, boundTo(elapsed * lerpSpeed, 0, 1));
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
