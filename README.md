#meteor-view

## Installation

A view class wrapping meteor's template helpers, events and callbacks, inspired by backbone.js view. 

### Atmosphere  

* Go to [https://atmosphere.meteor.com/](https://atmosphere.meteor.com/) and follow the instructions
* Call `> mrt add view` in the meteor projects root 

### Manually

* Download the meteor project from github
* Download and add the `meteor-view` package to the packages folder of meteor
* run the meteor script from the folder you checked the github repo out into, not the locally installed  one


## Meteor.View

### create `Meteor.View.create(String name, Object properties)`

To create a new view instance, use this method.  
`Meteor.View.create` returns a view instance, **not** a constructor function! Anyway, because of Meteor's nature, you probably won't need the view instance later.

* `name` must be the name of the template you want to create the view for  
* `properties` must be an object literal and will be merged into the new view's prototype.

### initialize (constructor)
If a `initialize` method is present in the properties object, it will be called when the instance is created

    view = Meteor.view.create("foo", {
        initialize: function() {
            console.log(this.name + " view created");
        }
    });

### helpers
A map for all the template helpers used.

**The template**

    <template name="foo">
        {{#each articles}}
            ...
        {{/each}}
    </template>


**The view**

    view = Meteor.view.create("foo", {
        helpers: {
            "articles" : "getArticles"
        },
        getArticles: function() {
            return Articles.find();
        }
    });

**The context/`this` in the callback is bound to the view instance!** 

### elements
A map representing dom elements you want to use later. Each key value pair of this map is defined like so:    
`{'String selector' : 'String instanceMember'}`.

    view = Meteor.view.create("foo", {
        elements: {
            ".foo" : "foo",
            ".bar" : "bar"
        },
        
        ...
        
        onClick: function(){
            $(this.foo).hide();
            $(this.bar).show();
        }
    });
    
Internally, the template instance method [`.findAll(selector)`](http://docs.meteor.com/#template_findAll) of Meteor 
is used to find the elements. So you'll have an array with dom elements in your hand. 

There won't be any elements if the template hasn't been rendered or is empty for whatever reasons.

**If you care for older browsers don't use elements! It uses `__defineGetter__` to return the current dom elements.** 

### events
A map describing the events handled in a template. Supports events as described in the 
[meteor doc](http://docs.meteor.com/#template_events).

    view = Meteor.view.create("foo", {
        events: {
            "click a.archive-article": "onArchive"
        },
        
        ...
        
        onArchive: function(evt){
            evt.preventDefault();
            this.archive(evt.currentTarget);
        },
        archive: function(link) {
            ...
        }
    });

**The context/`this` in the callback is bound to the view instance and not the dom element!** 

### callbacks
A map of callbacks (rendered, created, destroyed) for this template.  

    view = Meteor.view.create("foo", {
        callbacks: {
            "rendered": "onRendered"
        },
        onRendered: function(template) {
            template.findAll('.foo').forEach((el) ->
              el.style.background = "red";
            )
        }
    });
    
* The callback function's context/`this` will be bound to the view instance. 
* The first argument will **always** be the template instance you would normally access with `this`
* All other parameters will follow the template instance