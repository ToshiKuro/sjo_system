$(function(){

  id1 = setInterval(function() {
    var select_date = $('#date').val();

    $.ajax({
      url:  '/',
      type: 'get',
      data: { date: select_date },
      dataType: 'json'
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
