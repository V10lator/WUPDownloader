/***************************************************************************
 * This file is part of NUSspli.                                           *
 * Copyright (c) 2020-2021 V10lator <v10lator@myway.de>                    *
 *                                                                         *
 * This program is free software; you can redistribute it and/or modify    *
 * it under the terms of the GNU General Public License as published by    *
 * the Free Software Foundation; either version 2 of the License, or       *
 * (at your option) any later version.                                     *
 *                                                                         *
 * This program is distributed in the hope that it will be useful,         *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 * GNU General Public License for more details.                            *
 *                                                                         *
 * You should have received a copy of the GNU General Public License along *
 * with this program; if not, write to the Free Software Foundation, Inc., *
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.             *
 ***************************************************************************/

#include <wut-fixups.h>

#include <input.h>
#include <installer.h>
#include <renderer.h>
#include <status.h>
#include <menu/utils.h>

#include <string.h>

void drawInstallerMenuFrame(const char *name, bool fromUSB, bool keepFiles)
{
	startNewFrame();
	
	textToFrame(0, 0, name);
	
	lineToFrame(MAX_LINES - 6, SCREEN_COLOR_WHITE);
	textToFrame(MAX_LINES - 5, 0, "Press \uE000 to install to USB");
	textToFrame(MAX_LINES - 4, 0, "Press \uE002 to install to NAND");
	textToFrame(MAX_LINES - 3, 0, "Press \uE001 to return");
	
	lineToFrame(MAX_LINES - 2, SCREEN_COLOR_WHITE);
	if(fromUSB)
		textToFrame(MAX_LINES - 1, 0, "WARNING: Files on USB will always be deleted after installing!");
	else
	{
		char *toFrame = getToFrameBuffer();
		strcpy(toFrame, "Press \uE07B to ");
		strcat(toFrame, keepFiles ? "delete" : "keep");
		strcat(toFrame, " files after the installation");
		textToFrame(MAX_LINES - 1, 0, toFrame);
	}
	
	drawFrame();
}

void installerMenu(const char *dir)
{
	bool fromUSB = dir[3] == ':';
	bool keepFiles = !fromUSB;
	char name[strlen(dir) + 1];
	if(fromUSB)
		strcpy(name, dir);
	else
	{
		strcpy(name, "SD:");
		strcat(name, dir + 18);
	}
	
	drawInstallerMenuFrame(name, fromUSB, keepFiles);
	
	while(AppRunning())
	{
		if(app == APP_STATE_BACKGROUND)
			continue;
		if(app == APP_STATE_RETURNING)
			drawInstallerMenuFrame(name, fromUSB, keepFiles);
		
		showFrame();
		
		if(vpad.trigger & VPAD_BUTTON_A)
		{
			install(name, false, fromUSB, dir, true, keepFiles);
			return;
		}
		if(vpad.trigger & VPAD_BUTTON_B)
			return;
		if(vpad.trigger & VPAD_BUTTON_X)
		{
			install(name, false, fromUSB, dir, false, keepFiles);
			return;
		}
		
		if(vpad.trigger & VPAD_BUTTON_LEFT)
		{
			keepFiles = !keepFiles;
			drawInstallerMenuFrame(name, fromUSB, keepFiles);
		}
	}
}
