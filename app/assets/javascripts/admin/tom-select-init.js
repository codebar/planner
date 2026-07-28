// TomSelect for admin member lookup
// jQuery 1.12.4 ready promise silently drops callbacks registered after resolution
// (https://github.com/jquery/jquery/issues/2473). Use native DOMContentLoaded instead.
(function() {
  function init() {
    if ($('#member_lookup_id').length) {
      new TomSelect('#member_lookup_id', {
        placeholder: 'Type to search members...',
        valueField: 'id',
        labelField: 'full_name',
        searchField: ['full_name', 'email'],
        create: false,
        loadThrottle: 300,
        shouldLoad: function(query) {
          return query.length >= 3;
        },
        load: function(query, callback) {
          fetch('/admin/members/search?q=' + encodeURIComponent(query))
            .then(response => response.json())
            .then(json => callback(json))
            .catch(function() { callback(); });
        },
        render: {
          option: function(item, escape) {
            return '<div>' + escape(item.full_name) + ' <small class="text-muted">' + escape(item.email) + '</small></div>';
          }
        }
      });

      $('#member_lookup_id').on('change', function() {
        $('#view_profile').attr('href', '/admin/members/' + $(this).val());
      });
    }

    // TomSelect for meeting invitation member lookup
    if ($('#meeting_invitations_member').length) {
      new TomSelect('#meeting_invitations_member', {
        placeholder: 'Type to search members...',
        valueField: 'id',
        labelField: 'full_name',
        searchField: ['full_name', 'email'],
        create: false,
        loadThrottle: 300,
        shouldLoad: function(query) {
          return query.length >= 3;
        },
        load: function(query, callback) {
          fetch('/admin/members/search?q=' + encodeURIComponent(query))
            .then(response => response.json())
            .then(json => callback(json))
            .catch(function() { callback(); });
        },
        render: {
          option: function(item, escape) {
            return '<div>' + escape(item.full_name) + ' <small class="text-muted">' + escape(item.email) + '</small></div>';
          },
          no_results: function() {
            return '<div class="no-results">No members found</div>';
          }
        }
      });
    }

    // TomSelect for meeting organisers (multi-select)
    if ($('#meeting_organisers').length) {
      new TomSelect('#meeting_organisers', {
        plugins: ['remove_button'],
        placeholder: 'Type to search members...',
        valueField: 'id',
        labelField: 'full_name',
        searchField: ['full_name', 'email'],
        create: false,
        loadThrottle: 300,
        shouldLoad: function(query) {
          return query.length >= 3;
        },
        load: function(query, callback) {
          fetch('/admin/members/search?q=' + encodeURIComponent(query))
            .then(response => response.json())
            .then(json => callback(json))
            .catch(function() { callback(); });
        },
        render: {
          option: function(item, escape) {
            return '<div>' + escape(item.full_name) + ' <small class="text-muted">' + escape(item.email) + '</small></div>';
          },
          no_results: function() {
            return '<div class="no-results">No members found</div>';
          }
        }
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
