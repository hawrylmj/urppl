$(document).ready(function(){
  // Activates the Carousel
  $('.carousel').carousel({
    interval: 5000
  })

  // Activates Tooltips for Social Links
  $('.tooltip-social').tooltip({
    selector: "a[data-toggle=tooltip]"
  })
  $("ul.example").sortable()
  $("#menu-toggle").click(function(e) {
        e.preventDefault();
        $("#wrapper").toggleClass("active");
    });
  /*$('.list-group li').click(function(){
     console.log("test");
  });*/
  $('.plus').click(function(){
     $('#myModal').modal('toggle');
  });
  $('.more').click(function(){
     console.log("test");
    $('.more').siblings().removeClass('hidden');
    //this.closest('li').toggleClass('hidden');
  });
  
});

var adjustment

$("ul.simple_with_animation").sortable({
  group: 'simple_with_animation',
  pullPlaceholder: false,
  exclude: '.title, .list-footer, .plus, .more',
  // animation on drop
  onDrop: function  (item, targetContainer, _super) {
    var clonedItem = $('<li/>').css({height: 0})
    item.before(clonedItem)
    clonedItem.animate({'height': item.height()})
    
    item.animate(clonedItem.position(), function  () {
      clonedItem.detach()
      _super(item)
    })
  },

  // set item relative to cursor position
  onDragStart: function ($item, container, _super) {
    var offset = $item.offset(),
    pointer = container.rootGroup.pointer

    adjustment = {
      left: pointer.left - offset.left,
      top: pointer.top - offset.top
    }

    _super($item, container)
  },
  onDrag: function ($item, position) {
    $item.css({
      left: position.left - adjustment.left,
      top: position.top - adjustment.top
    })
  }
  
});
