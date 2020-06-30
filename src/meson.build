executable(
    meson.project_name(),
    'Application.vala',
    'Settings.vala',
    'Window.vala',
    'Services/FileRoutines.vala',
    'Services/Path.vala',
    'Services/System.vala',
    'Widgets/Notebook.vala',
    'Widgets/Dialogs/Dialog.vala',
    'Widgets/Dialogs/FileChooser.vala',
    'Widgets/Dialogs/SaveDialog.vala',
    'Widgets/Tab/Tab.vala',
    'Widgets/Tab/IOPane.vala',
    'Widgets/Tab/SourceView/BracketsCompletion.vala',
    'Widgets/Tab/SourceView/CommentToggler.vala',
    'Widgets/Tab/SourceView/SnippetInserter.vala',
    'Widgets/Tab/SourceView/SourceView.vala',
    dependencies: [
        dependency('gee-0.8'),
        dependency('gtk+-3.0'),
        dependency('gtksourceview-3.0'),
        dependency('granite'),
        dependency('threads'),
        meson.get_compiler('vala').find_library('posix')
    ],
    install: true
)