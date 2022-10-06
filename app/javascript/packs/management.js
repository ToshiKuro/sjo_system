$(function(){

  if ($('#title').text() == '運航管理画面') {
    //id1 = setInterval(function() {
    //  location.reload();
    //}, 300000);
  }

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
