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

public class V.Application : Gtk.Application {
    public static string APP_ID = "com.github.navaneethp123.volatile";
    public static string APP_NAME = "Volatile";
    public static V.Settings settings = new V.Settings();
    
    public Application() {
        Object(
            application_id: APP_ID,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate() {
        var window = new V.Window(this);
        window.show_all();
    }

    public static int main(string[] args) {
        var app = new V.Application();
        return app.run(args);
    }
}