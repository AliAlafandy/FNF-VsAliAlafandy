package states;

import flixel.FlxSubState;
import flixel.FlxG;

import flixel.text.FlxText;
import flixel.effects.FlxFlicker;

import lime.app.Application;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;

class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var bg:FlxSprite;

	#if mobile
	var warnTextMobile:FlxText;
	#else
	var warnText:FlxText;
	#end

	override function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFF000080;
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x330000FF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);

		var ramGB:Float = Math.round(getSystemRAM() * 100) / 100;
		var ramGuide:Float = 6;

		#if mobile
		var warnMobile:String = "Hey, yoo!!\n
			This Mod needs at least " + ramGuide + " GB of RAM to run nicely.\n
			System Detected RAM: " + ramGB + " GB.\n
			Also,\n
			This Mod contains some flashing lights!\n
			Press A to continue and disable them now or go to Options Menu.\n
			Press B to ignore this message.\n
			You've been warned!";

		var guhMobile:String = "Hey, yoo!!\n
			This Mod contains some flashing lights!\n
			Press A to continue and disable them now or go to Options Menu.\n
			Press B to ignore this message.\n
			You've been warned!";
		#else
		var warn:String = "Hey, yoo!!\n
			This Mod needs at least " + ramGuide + " GB of RAM to run nicely.\n
			System Detected RAM: " + ramGB + " GB.\n
			Also,\n
			This Mod contains some flashing lights!\n
			Press ENTER to continue and disable them now or go to Options Menu.\n
			Press ESCAPE to ignore this message.\n
			You've been warned!";

		var guh:String = "Hey, yoo!!\n
			This Mod contains some flashing lights!\n
			Press ENTER to continue and disable them now or go to Options Menu.\n
			Press ESCAPE to ignore this message.\n
			You've been warned!";
		#end

		if (ramGB < ramGuide) // 3.49
		{
			#if mobile
			warnTextMobile = new FlxText(0, 0, FlxG.width, warnMobile, 32);
			warnTextMobile.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			warnTextMobile.screenCenter(XY);
			add(warnTextMobile);
			#else
			warnText = new FlxText(0, 0, FlxG.width, warn, 32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			warnText.screenCenter(XY);
			add(warnText);
			#end

			trace('Warning: System has less than 4 GB of RAM. Detected RAM: ' + ramGB + ' GB');
		} else {
			#if mobile
			warnTextMobile = new FlxText(0, 0, FlxG.width, guhMobile, 32);
			warnTextMobile.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			warnTextMobile.screenCenter(XY);
			add(warnTextMobile);
			#else
			warnText = new FlxText(0, 0, FlxG.width, guh, 32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			warnText.screenCenter(XY);
			add(warnText);
			#end

			trace('System has sufficient RAM: ' + ramGB + ' GB');
		}

		#if mobile
		addTouchPad("NONE", "A_B");
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
	
				if(!back) {
					ClientPrefs.data.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));

					#if mobile
					FlxFlicker.flicker(warnTextMobile, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
					#else
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
					#end
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));

					#if mobile
					FlxTween.tween(warnTextMobile, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
					#else
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
					#end
				}
			}
		}
		super.update(elapsed);
	}

	function getSystemRAM():Float {
		#if windows
		var process = new Process("wmic", ["OS", "get", "TotalVisibleMemorySize"]);
		var output = process.stdout.readAll().toString();
		process.close();

		var lines = output.split("\n");
		for (line in lines) {
		var trimmed = StringTools.trim(line);
		if (~/^\d+$/.match(trimmed)) {
			return Std.parseInt(trimmed) / (1024 * 1024); 
		}}
		#elseif linux
		var process = new Process("grep", ["MemTotal", "/proc/meminfo"]);
		var output = process.stdout.readAll().toString();
		process.close();

		var parts = output.split(":");
		if (parts.length > 1) {
			var kbRam = Std.parseInt(parts[1].replace("kB", "").trim());
			return kbRam / (1024 * 1024);
		}
		#elseif mobile
		return 4;
		// return lime.system.System.totalMemory / (1024 * 1024 * 1024);
		#end

		return 0;
	}
}
