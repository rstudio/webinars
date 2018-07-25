/*
 * NOTE: this JavaScript is a total hack-job and shouldn't be taken seriously
 * as an example for anything.
 */




/* Well, it's due in 2 days, so I guess we're using jQuery...
 */

$(document).ready(function(){
	// The emoji whose details we're viewing
	var detail = null; 

  // Whether or not the dropdown emoji selector is open.
  var selectorOpen = false;
  var es = $('#emoji');

  // Listen
  es.focusout(function(){
    selectorOpen = false;
  });

  es.focus(function(){
    selectorOpen = true;
  });

  es.on('change', function(){
    if (this.value === 'All'){
      detail = null;
    } else {
      detail = this.value;
    }
    update(true);

    // Force deselection of the selector to trigger the selectorOpen event above.
    setTimeout(function(){
      $('#titlelink').focus();
    }, 0);
  });

  var base = '<YOUR BASE URL HERE>'
  //var base = 'https://plumber.rstudio.org/plumber/';
  
  $('#call').click(function(){
    if (detail === null){
      alert("Cannot call now.");
    } else {
      $.post(base + 'callall/' + detail);
    }
  });

	function updateDetails(detail) {
    var noonce = Date.now()
		if (!detail){
      var url = base + 'barplot?n=' + noonce;
      $('#plot').attr('src', url).show();
      $('#map').hide();
		} else {
      $('#plot').hide()
      var url = base + 'heatmap/' + detail + '?n=' + noonce;
      $('#map').attr('src', url).show();
    }
	}

	function update(force){
    // Only update the details if we're looking at the overview chart, or if
    // we were forced to update.
    if (detail === null || force){
      console.log("Updating now");
      updateDetails(detail);
    }

    if (selectorOpen) {
      // Don't update the table while trying to select something.
      return;
    }

    // Get the table of emojis
    $.ajax(base + 'table').done(function(tbl){
      // Get the current value;
      var val = es.val();

      es.find('option').remove().end();

      es[0].add(new Option('All', 'All'));
      tbl.map(function(e){
        es[0].add(new Option(e.emo + ' (' + e.count + ')', e.emo, false, e.emo === val));
      });
    }).fail(function(e){
      console.log("Unable to download table!");
      console.log(e);
    });
	}

	setInterval(update, 5000);
	update(true);
});

