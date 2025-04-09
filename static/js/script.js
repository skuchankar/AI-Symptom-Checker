// static/js/script.js

document.addEventListener('DOMContentLoaded', () => {
  const feedbackForm = document.querySelector('form');
  const textarea = document.querySelector('textarea');

  if (feedbackForm && textarea) {
    feedbackForm.addEventListener('submit', (e) => {
      const feedbackText = textarea.value.trim();
      if (feedbackText.length < 5) {
        alert("Please enter more detailed feedback.");
        e.preventDefault();
      }
    });
  }
});
