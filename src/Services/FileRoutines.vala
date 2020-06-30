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

namespace V.FileRoutines {
    Gee.ArrayList<string> get_file_names(string dir_path) {
        var file_names = new Gee.ArrayList<string>();
        try {
            var dir_file = File.new_for_path(dir_path);
            var enumerator = dir_file.enumerate_children("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null);
            FileInfo info;
            while((info = enumerator.next_file()) != null) {
                file_names.add(info.get_name());
            }
        } catch(Error e) {
            print("Error in V.File.get_file_names: %s\n", e.message);
        }
        return file_names;
    }

    string get_nonconflicting_file_name_in(string dir_path) {
        var existing_file_names = get_file_names(dir_path);
        int i = existing_file_names.size + 1;
        var file_name= "voltl_" + i.to_string() + ".cpp";
        while(existing_file_names.contains(file_name)) {
            ++i;
            file_name = "voltl_" + i.to_string() + ".cpp";
        }
        return file_name;
    }

    File get_new_temp_file_with_content_from(string? template_name) {
        var file_name = get_nonconflicting_file_name_in(V.Path.temp_dir());
        var file_path = V.Path.temp_dir() + file_name;
        var file = File.new_for_path(file_path);

        string contents = "";
        if(template_name != null) {
            var template_path = V.Path.templates_dir() + template_name;
            try {
                var template_file = File.new_for_path(template_path);
                if(template_file.query_exists()) FileUtils.get_contents(template_path, out contents);
            } catch(Error e) {
                print("Error while getting template content in V.FileRoutines.create_temp_file_with_content_from(string): %s\n", e.message);
            }
        }

        try {
            FileUtils.set_contents(file_path, contents);
        } catch(Error e) {
            print("Error loading template to new file in V.FileRoutines.create_temp_file_with_content_from(string): %s\n", e.message);
        }

        return file;
    }
}