/*
    Copyright (C) 2020  Navaneeth P <navaneethp123@outlook.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

namespace V.Path { 
    public string volatile_dir() {
        return Environment.get_home_dir() + "/Documents/Volatile/";
    }

    public string templates_dir() {
        return volatile_dir() + "Templates/";
    }

    public string temp_dir() {
        return volatile_dir() + "Temp/";
    }

    public string snippets_dir() {
        return volatile_dir() + "Snippets/";
    }

    public string executables_dir() {
        return volatile_dir() + "Executables/";
    }

    public string inputs_dir() {
        return volatile_dir() + "Inputs/";
    }
}