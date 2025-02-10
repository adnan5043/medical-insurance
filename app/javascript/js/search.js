document.addEventListener("DOMContentLoaded", function () {
  const searchInput = document.getElementById("search-input");
  const clearButton = document.getElementById("clear-button");
  const searchForm = document.getElementById("search-form");

  searchInput.addEventListener("input", function () {
    clearTimeout(this.delay);
    this.delay = setTimeout(function () {
      searchForm.submit();
    }, 500);

    clearButton.style.display = searchInput.value ? "block" : "none";
  });

  clearButton.addEventListener("click", function () {
    searchInput.value = "";
    clearButton.style.display = "none";
    searchForm.submit(); 
  });

  clearButton.style.display = searchInput.value ? "block" : "none";
});
