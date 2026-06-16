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

// Click-to-enlarge video lightbox, used by project landing pages
document.addEventListener('DOMContentLoaded', function () {
    const triggers = document.querySelectorAll('[data-lightbox-src]');
    if (!triggers.length) return;

    const overlay = document.createElement('div');
    overlay.className = 'lightbox-overlay';
    overlay.setAttribute('aria-hidden', 'true');
    overlay.innerHTML =
        '<div class="lightbox-content">' +
            '<button type="button" class="lightbox-close" aria-label="Close video">×</button>' +
            '<video class="lightbox-video" controls loop playsinline></video>' +
        '</div>';
    document.body.appendChild(overlay);

    const video = overlay.querySelector('.lightbox-video');
    const closeBtn = overlay.querySelector('.lightbox-close');

    function openLightbox(src) {
        video.src = src;
        overlay.classList.add('is-open');
        overlay.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
        const playback = video.play();
        if (playback && playback.catch) playback.catch(function () {});
        closeBtn.focus();
    }

    function closeLightbox() {
        overlay.classList.remove('is-open');
        overlay.setAttribute('aria-hidden', 'true');
        video.pause();
        video.removeAttribute('src');
        video.load();
        document.body.style.overflow = '';
    }

    triggers.forEach(function (trigger) {
        trigger.addEventListener('click', function () {
            openLightbox(trigger.getAttribute('data-lightbox-src'));
        });

        // Play the inline preview on hover, reset when the pointer leaves
        const preview = trigger.querySelector('video');
        if (preview) {
            trigger.addEventListener('mouseenter', function () {
                const playback = preview.play();
                if (playback && playback.catch) playback.catch(function () {});
            });
            trigger.addEventListener('mouseleave', function () {
                preview.pause();
                preview.currentTime = 0;
            });
        }
    });

    overlay.addEventListener('click', function (e) {
        if (e.target === overlay) closeLightbox();
    });
    closeBtn.addEventListener('click', closeLightbox);
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && overlay.classList.contains('is-open')) closeLightbox();
    });
});
