$(function(){

  id1 = setInterval(function() {
    $.ajax({
      url:  '/get_flight_data',
      type: 'get'
    })
    .done(function(data) {
      if ($('#title').text() == '運航管理画面') {
        location.reload();
      }
    })
  }, 300000);

  id2 = setInterval(function() {
    $.ajax({
      url:  '/forward_arrival_information',
      type: 'get'
    })
  }, 180000);

  $('#title').click(function() {
    clearInterval(id1);
    clearInterval(id2);
  })

});
