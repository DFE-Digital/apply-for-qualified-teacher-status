function outerHeight(el) {
  var height = el.offsetHeight;
  var style = window.getComputedStyle(el, "");

  height += parseInt(style.marginTop) + parseInt(style.marginBottom);
  return height;
}

export default outerHeight;
