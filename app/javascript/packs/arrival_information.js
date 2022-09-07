$(function(){
  if ($('#title').text() == '＜運航管理者監視画面＞') {
    id = setInterval(function() {
      location.reload()
    }, 5000);

    $('#title').click(function() {
      clearInterval(id);
    })
  }
});
