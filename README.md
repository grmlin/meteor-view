#meteor-view

## Installation

A view class wrapping meteor's template helpers, events and callbacks, inspired by backbone.js view.  
You can see a working example in my diary project [here](https://github.com/grmlin/diary/blob/master/client/cs/views/Article.coffee).

### Atmosphere  

* Go to [https://atmosphere.meteor.com/](https://atmosphere.meteor.com/) and follow the instructions
* Call `> mrt add view` in the meteor projects root 

### Manually

* Download the meteor project from github
* Download and add the `meteor-view` package to the packages folder of meteor
* run the meteor script from the folder you checked the github repo out into, not the locally installed  one


## Meteor.View

### create `Meteor.View.create(Object properties)`

To create a new view class, use this method.  
`Meteor.View.create` returns a view class! 

* `properties` must be an object literal and will be merged into the new view's prototype.

#### View instantiation
A view class has to be instantiated with `new`, and the first argument of the constructor call **has to be the template name** used with this view instance.  
All other arguments you pass into the constructor are later available in the `initialize` method.

    var FooView = Meteor.View.create({...});
    myView = new FooView("foo_template", [*args]);

--- 

### <span style="font-weight:normal">properties.</span>initialize (constructor)
If a `initialize` method is present in the properties object, it will be called when the instance is created

    View = Meteor.view.create({
        initialize: function(foo) {
            console.log(foo); //prints "Hello World"
        }
    });
    
    ...
    
    view = new View("a_template", "Hello World");

### <span style="font-weight:normal">properties.</span>helpers
A map for all the template helpers used.

**The template**

    <template name="foo">
        {{#each articles}}
            ...
        {{/each}}
    </template>


**The view**

    View = Meteor.view.create({
        helpers: {
            "articles" : "getArticles"
        },
        getArticles: function() {
            return Articles.find();
        }
    });

**The context/`this` in the callback is bound to the view instance!** 

### <span style="font-weight:normal">properties.</span>elements
A map representing dom elements you want to use later. Each key value pair of this map is defined like so:    
`{'String selector' : 'String instanceMember'}`.

    View = Meteor.view.create({
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

### <span style="font-weight:normal">properties.</span>events
A map describing the events handled in a template. Supports events as described in the 
[meteor doc](http://docs.meteor.com/#template_events).

    View = Meteor.view.create({
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

### <span style="font-weight:normal">properties.</span>callbacks
A map of callbacks (rendered, created, destroyed) for this template.  

    View = Meteor.view.create({
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