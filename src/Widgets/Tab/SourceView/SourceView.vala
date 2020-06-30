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

public class V.SourceView : Gtk.SourceView {
    private const string SOURCE_VIEW_DARK = "volatile-vapors";
    private const string SOURCE_VIEW_FONT = "textview { font-family: Monospace; font-size: 11pt; }";

    private Gtk.SourceLanguageManager language_manager;
    private Gtk.SourceStyleSchemeManager style_scheme_manager;
    private V.Editor.BracketsCompletion brackets_completion;

    public SourceView() {
        Object(
            auto_indent: true,
            highlight_current_line: true,
            insert_spaces_instead_of_tabs: true,
            indent_width: 4,
            tab_width: 4,
            show_line_numbers: true,
            smart_backspace: true
        );
    }

    construct {
        language_manager = Gtk.SourceLanguageManager.get_default();
        ((Gtk.SourceBuffer) buffer).language = language_manager.get_language("cpp");
        
        style_scheme_manager = Gtk.SourceStyleSchemeManager.get_default();
        ((Gtk.SourceBuffer) buffer).set_style_scheme(style_scheme_manager.get_scheme(SOURCE_VIEW_DARK));

        try {
            var cssp = new Gtk.CssProvider();
            cssp.load_from_data(SOURCE_VIEW_FONT);
            this.get_style_context().add_provider(cssp, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch(Error e) {}
        
        brackets_completion = new V.Editor.BracketsCompletion();
        brackets_completion.activate(this);

        populate_popup.connect((menu) => {
            var menu_item = new Gtk.MenuItem.with_label("Insert Snippet");
            menu.add(menu_item);
            menu_item.activate.connect(insert_snippet);
            menu.show_all();
        });
    }

    public void toggle_comment() {
        V.Editor.CommentToggler.toggle_comment((Gtk.SourceBuffer) buffer);
    }

    public void insert_snippet() {
        V.Editor.SnippetInserter.insert_snippet(this);
    }
}