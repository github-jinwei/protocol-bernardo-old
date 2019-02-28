//
//  ncurses.cpp
//  Music Composer
//
//  Created by Valentin Dufois on 24/11/2017.
//  Copyright © 2017 Valentin Dufois. All rights reserved.
//

#include "ncurses.hpp"

void nCurses::init()
{
	initscr();
	cbreak();
	noecho();
	start_color();
	keypad(stdscr, TRUE);
	nodelay(stdscr, TRUE);

	//Default colors
	init_pair(1, COLOR_WHITE, COLOR_BLACK);
	attron(COLOR_PAIR(1));
}

nCursesVoidElement nCurses::move(int col, int row)
{
	::move(row, col);
	return 0;
}

//PRINTERS
nCurses::Print nCurses::print;


//Graphics
void nCurses::printGraphic(const int &col, const int &row, const std::u32string &toPrint)
{
	move(col, row);

	for (std::u32string::const_iterator c = toPrint.begin(); c != toPrint.end(); c++)
	{
		switch ((int)*c)
		{
			case '|':  print << ACS_VLINE;    break;
			case '-':  print << ACS_HLINE;    break;
			case 9488: print << ACS_URCORNER; break; // ┐
			case 9492: print << ACS_LLCORNER; break; // └
			case 9500: print << ACS_LTEE;     break; // ├
			case 9508: print << ACS_RTEE;     break; // ┤
			case 9516: print << ACS_TTEE;     break; // ┬
			case 9524: print << ACS_BTEE;     break; // ┴
			case 9496: print << ACS_LRCORNER; break; // ┘
			case 9484: print << ACS_ULCORNER; break; // ┌
			default:
				print << (char)*c;
		}
	}
}

//STYLE HANDLER
int nCurses::m_currentForeground = COLOR_WHITE;
int nCurses::m_currentBackground = COLOR_BLACK;
int nCurses::m_lastColorID = 1;

void nCurses::clear()
{
	//STYLING
	clearStyling();

	m_lastColorID = 1;
}

void nCurses::clearStyling()
{
	//STYLE
	setDefaultStyle();

	//COLORS
	setDefaultColors();
}

void nCurses::setDefaultStyle()
{
	//Set all attributes to off
	attroff(A_BLINK);
	attroff(A_BOLD);
	attroff(A_UNDERLINE);
}

void nCurses::setDefaultColors()
{
	attroff(COLOR_PAIR(m_lastColorID));
	attron(COLOR_PAIR(1));

	m_currentForeground = COLOR_WHITE;
	m_currentBackground = COLOR_BLACK;
}

nCursesVoidElement nCurses::setBold()
{
	attron(A_BOLD);
	return 0;
}

nCursesVoidElement nCurses::removeBold()
{
	attroff(A_BOLD);
	return 0;
}

nCursesVoidElement nCurses::setBlink()
{
	attron(A_BLINK);
	return 0;
}

nCursesVoidElement nCurses::removeBlink()
{
	attroff(A_BLINK);
	return 0;
}

nCursesVoidElement nCurses::setUnderline()
{
	attron(A_UNDERLINE);
	return 0;
}

nCursesVoidElement nCurses::removeUnderline()
{
	attroff(A_UNDERLINE);
	return 0;
}

void nCurses::setForeground(int nCursesColor)
{
	m_currentForeground = nCursesColor;
	updateColors();
}

void nCurses::setBackground(int nCursesColor)
{
	m_currentBackground = nCursesColor;
	updateColors();
}

void nCurses::setColors(int foregroundColor, int backgroundColor)
{
	m_currentForeground = foregroundColor;
	m_currentBackground = backgroundColor;
	updateColors();
}
void nCurses::updateColors()
{
	attroff(COLOR_PAIR(m_lastColorID));

	m_lastColorID++;

	init_pair(m_lastColorID, m_currentForeground, m_currentBackground);
	attron(COLOR_PAIR(m_lastColorID));
}


//DRAWING
void nCurses::box(const int &col, const int &row, const uint &width, const uint &height)
{
	//Angles
	print << mv(col            , row             ) << ACS_ULCORNER;
	print << mv(col + width - 1, row             ) << ACS_URCORNER;
	print << mv(col + width - 1, row + height - 1) << ACS_LRCORNER;
	print << mv(col            , row + height - 1) << ACS_LLCORNER;

	//borders
	hLine(col + 1        , row             , width - 2 );
	hLine(col + 1        , row + height - 1, width - 2 );
	vLine(col            , row + 1         , height - 2);
	vLine(col + width - 1, row + 1         , height - 2);

	//Fill all spaces to apply any style
	for(int i = 1; i < width-1; ++i)
		for(int j = 1; j < height-1; ++j)
			print << mv(col + i, row + j) << " ";


}

void nCurses::hLine(const int &col, const int &row, const uint &length)
{
	for(int i = 0; i < length; ++i)
		print << mv(col + i, row) << ACS_HLINE;
}

void nCurses::vLine(const int &col, const int &row, const uint &length)
{
	for(int i = 0; i < length; ++i)
		print << mv(col, row + i) << ACS_VLINE;
}
