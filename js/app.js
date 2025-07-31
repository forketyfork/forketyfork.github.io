// Import CSS files
import '../css/style.css';
import '../css/custom.css';
import '../css/fruity.css';

// Showing a CRT-style cursor instead of the mouse pointer
document.addEventListener('DOMContentLoaded', function () {
    console.log('Document is ready');
    const cursor = document.querySelector('.custom-cursor');

    document.addEventListener('mousemove', function (e) {
        cursor.style.left = (e.clientX - 6) + 'px';
        cursor.style.top = (e.clientY - 10) + 'px';
    });

    // Add hover effect
    const interactiveElements = document.querySelectorAll('a, button, input[type="submit"]');
    interactiveElements.forEach(element => {
        element.addEventListener('mouseenter', () => {
            cursor.style.transform = 'scale(1.5)';
        });
        element.addEventListener('mouseleave', () => {
            cursor.style.transform = 'scale(1)';
        });
    });
});
