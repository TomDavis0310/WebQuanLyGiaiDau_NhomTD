// Please see documentation at https://learn.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

// Xem thêm functionality for tournament descriptions
$(document).ready(function() {
    // Initialize all description elements with the class 'tournament-description'
    initializeDescriptions();

    // Re-initialize when content is loaded via AJAX
    $(document).on('ajaxComplete', function() {
        initializeDescriptions();
    });

    function initializeDescriptions() {
        // Find all elements with the class 'tournament-description'
        $('.tournament-description').each(function() {
            const description = $(this);
            const fullText = description.text();

            // If the description is longer than 150 characters, truncate it
            if (fullText.length > 150) {
                const truncatedText = fullText.substring(0, 150) + '...';

                // Create the HTML structure
                const truncatedElement = $('<span class="truncated-text">' + truncatedText + '</span>');
                const fullElement = $('<span class="full-text" style="display: none;">' + fullText + '</span>');
                const toggleButton = $('<button class="btn btn-sm btn-link text-primary p-0 ms-1 toggle-description">Xem thêm</button>');

                // Clear the original content and append the new elements
                description.empty().append(truncatedElement).append(fullElement).append(toggleButton);

                // Add click event to toggle button
                toggleButton.on('click', function() {
                    const button = $(this);
                    const truncated = description.find('.truncated-text');
                    const full = description.find('.full-text');

                    if (truncated.is(':visible')) {
                        truncated.hide();
                        full.show();
                        button.text('Thu gọn');
                    } else {
                        full.hide();
                        truncated.show();
                        button.text('Xem thêm');
                    }
                });
            }
        });
    }
});
