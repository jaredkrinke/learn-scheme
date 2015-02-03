$(function () {
    // Set up the editor
    var input = $('#editorInput');
    var output = $('#editorOutput');
    var execute = $('#editorExecute');

    // Create code editor for the input
    var editor;
    var evaluate = function () {
        var outputText;
        try {
            var inputText = editor.getValue();
            var result = interpreter.evaluate(inputText);
            if (result !== undefined) {
                outputText = interpreter.format(result);
            }
        } catch (e) {
            outputText = e.toString();
        }

        output.val(outputText);
    };

    // Set up basic evaluation and output
    var interpreter = new JSLisp.Interpreter();
    execute.click(function (e) {
        e.preventDefault();
        evaluate();
    });

    editor = CodeMirror.fromTextArea(input.get(0),
        {
            mode: 'scheme',
            extraKeys: {
                'Ctrl-Enter': evaluate
            }
        });

    // Function for popping up the code editor
    var editorModal = $('#editorModal');
    var showEditor = (function () {
        var newText = '';
        editorModal.on('shown.bs.modal', function () {
            editor.setValue(newText.trim());
            editor.focus();
            editor.execCommand('goDocEnd');
        });

        return function (text) {
            editorModal.modal('show');
            if (text !== undefined) {
                newText = text;
            }
        };
    })();

    $('#launchEditor').click(function () {
        showEditor(' ');
    });

    // Attach editor to code samples (via double-click and a button)
    var tryItButton = $('#tryItButton');
    $('div.container > pre').each(function () {
        var element = $(this);
        var text = element.text();
        var show = function () {
            showEditor(text);
        };

        element
            .dblclick(show)
            .prepend(tryItButton
                .clone()
                .removeClass('hidden')
                .click(show));
    });
});

