HTMLWidgets.widget({
  name: 'widgetsummarize',
  type: 'output',

  factory: function(el, width, height) {

    // Filter obj, returning a new obj containing only
    // values with keys in keys.
    var filterKeys = function(obj, keys) {
      var result = {};
      keys.forEach(function(k) {
        if (obj.hasOwnProperty(k))
          result[k]=obj[k];});
      return result;
    };

    return {
      renderValue: function(x) {

        // Make a data object with keys so we can easily update the selection
        var data = {};
        var data2 = {};
        var i;
        if (x.settings.crosstalk_key === null) {
          for (i=0; i<x.data.length; i++) {
            data[i] = x.data[x.settings.column][i];
            data2[i] = x.data[x.settings.column2][i];
          }
        } else {
          for (i=0; i<x.settings.crosstalk_key.length; i++) {
            data[x.settings.crosstalk_key[i]] = x.data[x.settings.column][i];
            data2[x.settings.crosstalk_key[i]] = x.data[x.settings.column2][i];
          }
        }

        //data = x.data;
        //data = x.data[x.settings.column];
        //data2 = x.data[x.settings.column2];

        console.log(data);
        console.log(data2);
        console.log(x.data);
        console.log(x.settings.crosstalk_key);
        console.log(Object.keys(data));
        //console.log(Object.values(x.data));

        // Update the display to show the values in d
        var update = function(d, d2) {
          // Get a simple vector. Don't use Object.values(), RStudio doesn't seem to support it.
          var values = [];
          var values2 = [];
          //console.log(d[x.settings.column]);

          for (var key in d) {
            if (d.hasOwnProperty(key)) {
              values.push(d[key]);}
          }

          for (var key2 in d2) {
            if (d2.hasOwnProperty(key2)) {
              values2.push(d2[key2]);}
          }

          console.log(values);
          console.log(values2);

          var value = 0;
          switch (x.settings.statistic) {
            case 'count':
              value = values.length;
              break;
            case 'sum':
              value = values.reduce(function(acc, val) {return acc + val;}, 0);
              break;
            case 'mean':
              value = values.reduce(function(acc, val) {return acc + val;}, 0) / values.length;
              break;
          }
          var value2 = 0;
          switch (x.settings.statistic2) {
            case 'count':
              value2 = values2.length;
              break;
            case 'sum':
              value2 = values2.reduce(function(acc, val) {return acc + val;}, 0);
              break;
            case 'mean':
              value2 = values2.reduce(function(acc, val) {return acc + val;}, 0) / values2.length;
              break;
          }
          if (x.settings.column2 !== null) {
            if (x.settings.digits !== null) {
              value = value.toFixed(x.settings.digits);
              value2 = value2.toFixed(x.settings.digits);
            }
              el.innerText = value/value2;
          } else {
            el.innerText = value;
          }
       };

       // Set up to receive crosstalk filter and selection events
       var ct_filter = new crosstalk.FilterHandle();
       ct_filter.setGroup(x.settings.crosstalk_group);
       ct_filter.on("change", function(e) {
         if (e.value) {
           update(filterKeys(data, e.value),filterKeys(data2, e.value));
         } else {
           update(data, data2);
         }
       });

       var ct_sel = new crosstalk.SelectionHandle();
       ct_sel.setGroup(x.settings.crosstalk_group);
       ct_sel.on("change", function(e) {
         if (e.value && e.value.length) {
           update(filterKeys(data, e.value), filterKeys(data2, e.value)); //crosstalk function is named filteredKeys() in doc
         } else {
           update(data, data2);
         }
       });

       update(data, data2);
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
