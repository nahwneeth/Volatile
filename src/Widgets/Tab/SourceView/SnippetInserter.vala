/*
    BEGIN LICENSE
    Copyright (C) 2013 Mario Guerriero <mario@elementaryos.org>
    Copyright (C) 2020 Navaneeth P <navaneethp123@outlook.com>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.
    
    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses/>
    END LICENSE
*/

public class V.Editor.SnippetInserter {    
    public static bool insert_snippet(V.SourceView cur_source_view) {
        var cur_buff = cur_source_view.buffer;

        Gtk.TextIter start, end;
        cur_buff.get_selection_bounds(out start, out end);

        // If no selection, get the current word
        if(!cur_buff.has_selection) {
            while(true) {
                var s_char = end.get_char();
                if(s_char == '\0' || s_char == ' ' || s_char == '\t' || s_char == '\n') {
                    break;
                }
                end.forward_char();
            }

            while(true) {
                if(!start.backward_char()) {
                    break;
                }
                var s_char = start.get_char();
                if(s_char == '\0' || s_char == ' ' || s_char == '\t' || s_char == '\n') {
                    start.forward_char();
                    break;
                }
            }
        }

        var path_from_snip_dir = cur_buff.get_text(start, end, true);
        
        if(path_from_snip_dir == "") {
            return false;
        }

        try {
            DirUtils.create_with_parents(V.Path.snippets_dir(), 0755);
            var file = File.new_for_path(V.Path.snippets_dir() + path_from_snip_dir);
            var tab_to_spaces = string.nfill(cur_source_view.tab_width, ' ');

            FileInputStream inpt_strm = file.read();
            DataInputStream dis = new DataInputStream(inpt_strm);

            cur_buff.begin_user_action();
            cur_buff.delete_interactive(ref start, ref end, true);

            end = start;
            start.backward_chars(start.get_line_offset());
            var indent = string.nfill(cur_buff.get_text(start, end, true).replace("\t", tab_to_spaces).length, ' ');
            
            string line;
            while((line = dis.read_line()) != null) {
                cur_buff.insert_interactive(ref end, (line + "\n" + indent), -1, true);
            }

            cur_buff.end_user_action();
        } catch(Error e) {
            print("Insert Snippet: "+ e.message);
        }
        return true;
    }
}