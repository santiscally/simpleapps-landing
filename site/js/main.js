// Mobile menu toggle
(function(){
  var burger = document.querySelector('[data-menu-toggle]');
  var nav = document.getElementById('mobile-nav');
  if(burger && nav){
    burger.addEventListener('click', function(){
      var open = nav.classList.toggle('open');
      burger.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    nav.querySelectorAll('a').forEach(function(a){
      a.addEventListener('click', function(){
        nav.classList.remove('open');
        burger.setAttribute('aria-expanded','false');
      });
    });
  }
})();
// FAQ accordion: only one open at a time
(function(){
  var items = document.querySelectorAll('.faq-item');
  items.forEach(function(item){
    item.addEventListener('toggle', function(){
      if(item.open){
        items.forEach(function(other){ if(other !== item) other.open = false; });
      }
    });
    // reflect native open state as .open class for animation
    item.addEventListener('toggle', function(){
      item.classList.toggle('open', item.open);
    });
  });
  // init
  items.forEach(function(item){ item.classList.toggle('open', item.open); });
})();
