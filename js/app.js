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

    // Only ever play local mp4 asset paths through the lightbox
    const SAFE_SRC = /^\/[\w./-]+\.mp4$/;

    // Build the overlay via the DOM API rather than innerHTML
    const overlay = document.createElement('div');
    overlay.className = 'lightbox-overlay';
    overlay.setAttribute('role', 'dialog');
    overlay.setAttribute('aria-modal', 'true');
    overlay.setAttribute('aria-label', 'Video player');
    overlay.setAttribute('aria-hidden', 'true');

    const content = document.createElement('div');
    content.className = 'lightbox-content';

    const closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.className = 'lightbox-close';
    closeBtn.setAttribute('aria-label', 'Close video');
    closeBtn.textContent = '×';

    const video = document.createElement('video');
    video.className = 'lightbox-video';
    video.controls = true;
    video.loop = true;
    video.playsInline = true;

    content.appendChild(closeBtn);
    content.appendChild(video);
    overlay.appendChild(content);
    document.body.appendChild(overlay);

    let opener = null;
    let prevOverflow = '';

    function openLightbox(src, trigger) {
        if (!SAFE_SRC.test(src)) return;
        opener = trigger;
        prevOverflow = document.body.style.overflow;
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
        document.body.style.overflow = prevOverflow;
        if (opener && opener.focus) opener.focus();
        opener = null;
    }

    triggers.forEach(function (trigger) {
        trigger.addEventListener('click', function () {
            openLightbox(trigger.getAttribute('data-lightbox-src'), trigger);
        });

        // Play the inline preview on hover, reset to the poster when the pointer leaves
        const preview = trigger.querySelector('video');
        if (preview) {
            trigger.addEventListener('mouseenter', function () {
                const playback = preview.play();
                if (playback && playback.catch) playback.catch(function () {});
            });
            trigger.addEventListener('mouseleave', function () {
                preview.pause();
                preview.currentTime = 0;
                preview.load();
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
