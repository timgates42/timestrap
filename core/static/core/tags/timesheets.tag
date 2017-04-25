<timesheets>
    <p class="mb-4 clearfix">
        <button class="btn btn-primary btn-sm"
            data-url="{ previous }"
            if={ previous }
            onclick={ timesheetsPage }>
            <i class="fa fa-arrow-left" aria-hidden="true"></i> Previous
        </button>

        <button class="btn btn-primary btn-sm pull-right"
            data-url="{ next }"
            if={ next }
            onclick={ timesheetsPage }>
            Next <i class="fa fa-arrow-right" aria-hidden="true"></i>
        </button>
    </p>

    <form onsubmit={ submitTimesheet }>
        <table class="timesheets-table table table-striped table-sm w-100 d-none">
            <thead class="thead-inverse">
                <tr>
                    <th>Name</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <tr class="table-info">
                    <td>
                        <input type="text" class="form-control form-control-sm" ref="name" placeholder="Name">
                    </td>
                    <td class="text-right">
                        <button type="submit" class="btn btn-primary btn-sm">Add</button>
                    </td>
                </tr>
                <tr each={ timesheets }>
                    <td>{ name }</td>
                    <td class="text-right">
                        <a class="btn btn-warning btn-sm" onclick={ editTimesheet }>Edit</a>
                        <a class="btn btn-primary btn-sm" data-id="{ id }" onclick={ goToTasks }>Tasks</a>
                        <a class="btn btn-primary btn-sm" data-id="{ id }" onclick={ goToEntries }>Entries</a>
                    </td>
                </tr>
            </tbody>
        </table>
    </form>

    <p class="loading text-center my-5">
        <i class="fa fa-spinner" aria-hidden="true"></i>
    </p>

    <script>
        var tag = this;
        var loading;
        var timesheetsTable;

        getTimesheets(e, url) {
            fetch(url || timesheetsApiUrl, {
                credentials: 'include',
                headers: new Headers({
                    'content-type': 'application/json',
                })
            }).then(function(response) {
                return response.json();
            }).then(function(data) {
                loading = document.querySelector('.loading');
                timesheetsTable = document.querySelector('.timesheets-table');

                loading.classList.add('d-none');
                timesheetsTable.classList.remove('d-none');

                tag.update({
                    timesheets: data.results,
                    next: data.next,
                    previous: data.previous
                });
            });
        }

        tag.getTimesheets();

        timesheetsPage(e) {
            loading.classList.remove('d-none');
            timesheetsTable.classList.add('d-none');
            getEntries(e.currentTarget.getAttribute('data-url'));
        }

        goToTasks(e) {
            timesheet = e.target.dataset.id;
            document.location.href = tasksUrl + timesheet;
        }

        goToEntries(e) {
            timesheet = e.target.dataset.id;
            document.location.href = entriesUrl + timesheet;
        }

        // This is bad, need to figure out how riot expects inline editing
        editTimesheet(e) {
            let timesheet = e.item;
            let row = e.target.parentElement.parentElement;
            let columns = $(row).find('td');
            let csrfToken = Cookies.get('csrftoken');
            if ($(row).hasClass('editing')) {
                timesheet.name = $(columns[0]).find('input').val();
                fetch(timesheet.url, {
                    credentials: 'include',
                    headers: new Headers({
                        'content-type': 'application/json',
                        'X-CSRFToken': csrfToken
                    }),
                    method: 'put',
                    body: JSON.stringify(timesheet)
                }).then(function(response) {
                    return response.json();
                }).then(function(data) {
                    $(columns[0]).html(data.name);
                    $(columns[1]).find('.btn-warning').html('Edit');
                });
            } else {
                $(row).addClass('editing');
                $(columns[1]).find('.btn-warning').html('Save');
                $(columns[0]).html('<input type="text" class="form-control form-control-sm" value="' + timesheet.name + '">');
            }
        }

        submitTimesheet(e) {
            e.preventDefault();
            let csrfToken = Cookies.get('csrftoken');
            let formValues = {
                name: this.refs.name.value
            }
            fetch(timesheetsApiUrl, {
                credentials: 'include',
                headers: new Headers({
                    'content-type': 'application/json',
                    'X-CSRFToken': csrfToken
                }),
                method: 'post',
                body: JSON.stringify(formValues)
            }).then(function(response) {
                tag.getTimesheets();
            });
        }
    </script>
</timesheets>
