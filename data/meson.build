install_data (
    'gschema.xml',
    install_dir: join_paths (get_option ('datadir'), 'glib-2.0', 'schemas'),
    rename: meson.project_name () + '.gschema.xml'
)

install_data (
    'gtksourceview-dark.xml',
    install_dir: join_paths (get_option ('datadir'), 'gtksourceview-3.0', 'styles'),
    rename: 'volatile-vapors.xml'
)

icon_sizes = ['16', '32', '48', '64', '128']

icons_dir = join_paths (get_option ('datadir'), 'icons', 'hicolor')
foreach size : icon_sizes
    asset = join_paths ('assets', 'icons', '@0@x@0@'.format (size), '@0@.svg'.format (meson.project_name ()))
    
    install_data (
        asset,
        install_dir:  join_paths (icons_dir, '@0@x@0@'.format (size), 'apps'),
    )
endforeach

install_data (
    meson.project_name () + '.desktop.in.in',
    install_dir: join_paths (get_option ('datadir'), 'applications'),
    rename: meson.project_name () + '.desktop'
)

install_data (
    meson.project_name () + '.appdata.xml',
    install_dir: join_paths (get_option ('datadir'), 'metainfo')
)