Package.describe({
    summary : "View, package that provides a view class to manage meteor's template helpers and event handler."
});

Package.on_use(function (api) {
    api.use('coffeescript', 'server');
    api.add_files([
        'src/View.coffee'
    ], 'client'
    );
});