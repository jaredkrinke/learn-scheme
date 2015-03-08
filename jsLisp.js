(function (exports) {
    var tokenizerState = {
        initial: 0,
        inToken: 1,
        inString: 2,
    };

    var tokenize = function (input) {
        var output = [];
        var state = tokenizerState.initial;
        var token;
        // TODO: Implement comments
        for (var i = 0, count = input.length; i < count; i++) {
            switch (state) {
                case tokenizerState.initial:
                    {
                        switch (input[i]) {
                            case '(':
                            case ')':
                            case '\'':
                                output.push(input[i]);
                                break;

                            case ' ':
                            case '\n':
                            case '\r':
                                break;

                            case '"':
                                state = tokenizerState.inString;
                                token = input[i];
                                break;

                            default:
                                state = tokenizerState.inToken;
                                token = input[i];
                                break;
                        }
                    }
                    break;

                case tokenizerState.inToken:
                    {
                        switch (input[i]) {
                            case '(':
                            case ')':
                            case '\'':
                                output.push(token);
                                output.push(input[i]);
                                state = tokenizerState.initial;
                                break;

                            case ' ':
                            case '\n':
                            case '\r':
                                output.push(token);
                                state = tokenizerState.initial;
                                break;

                            default:
                                token += input[i];
                                break;
                        }
                    }
                    break;

                case tokenizerState.inString:
                    {
                        switch (input[i]) {
                            case '"':
                                output.push(token);
                                state = tokenizerState.initial;
                                break;

                            case '\\':
                                token += input[++i];
                                break;

                            default:
                                break;
                        }
                    }
                    break;
            }
        }

        switch (state) {
            case tokenizerState.inToken:
                output.push(token);
                break;
        
            case tokenizerState.inString:
                throw 'Expected "';
                break;
        }

        return output;
    };

    var createPair = function (head, tail) {
        return { head: head, tail: tail };
    };

    var isPair = function (o) {
        return o.head !== undefined;
    };

    var createList = function () {
        var list = null;
        for (var i = arguments.length - 1; i >= 0; i--) {
            list = createPair(arguments[i], list);
        }
        return list;
    };

    var appendList = function (a, b) {
        if (a === null) {
            return b;
        }

        var node = a;
        while (node.tail) {
            node = node.tail;
        }

        node.tail = b;

        return a;
    };

    // TODO: Better term since improper lists count?
    var isList = function (o) {
        return o === null || isPair(o);
    };

    var parseRecursive = function (input, state, single) {
        if (state.index < input.length) {
            var node = input[state.index++];
            if (node.length === 1) {
                switch (node[0]) {
                    case '(':
                        state.depth++;
                        node = parseRecursive(input, state);
                        break;

                    case ')':
                        state.depth--;
                        if (state.depth < 0) {
                            throw 'Extra ")"';
                        }
                        return null;

                    case '\'':
                        node = createList('quote', parseRecursive(input, state, true));
                        break;
                }
            }

            return single ? node : createPair(node, parseRecursive(input, state));
        } else if (state.depth > 0) {
            throw 'Missing ")"';
        }

        return null;
    };

    var parse = function (input) {
        return parseRecursive(input, { depth: 0, index: 0 });
    };

    var identifierPattern = /[^0-9,#();"'`|[\]{}][^,#();"'`|[\]{}]*/i;
    var parseIdentifier = function (text) {
        return (!isPair(text) && identifierPattern.test(text)) ? text : null;
    };

    var set = function (environment, key, value) {
        environment.head[key] = value;
    };

    var lookupEnvironment = function (environment, identifier) {
        for (; environment; environment = environment.tail) {
            if (environment.head[identifier] !== undefined) {
                return environment;
            }
        }
    };

    var lookup = function (environment, identifier) {
        environment = lookupEnvironment(environment, identifier);
        if (environment) {
            return environment.head[identifier];
        }
    };

    var createArithmeticFunction = function (identity, apply) {
        return function () {
            var result = identity;
            for (var i = 0, count = arguments.length; i < count; i++) {
                result = apply(result,  parseFloat(arguments[i]));
            }
            return result;
        };
    };

    var defaultEnvironment = createPair(
        {
            // Arithmetic
            '+': createArithmeticFunction(0, function (accumulator, value) { return accumulator + value; }),
            '-': function (a, b) { return (b === undefined) ? -parseFloat(a) : parseFloat(a) - parseFloat(b); },
            '*': createArithmeticFunction(1, function (accumulator, value) { return accumulator * value; }),
            '/': function (a, b) { return parseFloat(a) / parseFloat(b); },
            remainder: function (a, b) { return parseFloat(a) % parseFloat(b); },
            random: function (n) { return Math.floor(Math.random() * n); },

            'log': function (a) { return Math.log(parseFloat(a)); },
            'exp': function (a) { return Math.exp(parseFloat(a)); },

            '>': function (a, b) { return parseFloat(a) > parseFloat(b); },
            '>=': function (a, b) { return parseFloat(a) >= parseFloat(b); },
            '=': function (a, b) { return parseFloat(a) === parseFloat(b); },
            '<=': function (a, b) { return parseFloat(a) <= parseFloat(b); },
            '<': function (a, b) { return parseFloat(a) < parseFloat(b); },

            'number?': function (a) { return typeof(a) === 'number'; },
            // TODO: string? (need a way to differentiate identifiers from general strings

            // Symbols
            'eq?': function (a, b) { return a === b; },
            'symbol?': function (a) { return parseIdentifier(a) !== null; },
            'true': true,
            'false': false,
            '#t': true,
            '#f': false,

            // Lists
            cons: function (a, b) { return createPair(a, b); },
            car: function (pair) { return pair.head; },
            cdr: function (pair) { return pair.tail; },
            nil: null,
            'null?': function (x) { return x === null; },
            'pair?': function (x) { return isPair(x); },
            list: function () { return createList.apply(null, arguments); },
            // Note: Continued below

            // Output
            display: function (x) { process.stdout.write(x.toString()); },
            newline: function (x) { process.stdout.write('\n'); },

            // Error handling
            error: function (x) { throw x; },
        }, null
    );

    // cadr, caddr, etc. (up to a depth of 4)
    for (var depth = 2; depth <= 4; depth++) {
        // Create functions for each possible sequence of this depth
        for (var i = 0, count = (1 << depth); i < count; i++) {
            // Walk through each bit and create the label (1 means head, 0 means tail)
            var label = '';
            for (var j = 0; j < depth; j++) {
                label += ((i >> j) & 1) ? 'a' : 'd';
            }

            // E.g. caddr is implemented as car(cddr(...))
            var firstOperation = lookup(defaultEnvironment, 'c' + label.slice(0, 1) + 'r');
            var secondOperation = lookup(defaultEnvironment, 'c' + label.slice(1) + 'r');
            (function (firstOperation, secondOperation) {
                set(defaultEnvironment, 'c' + label + 'r', function (pair) { return firstOperation(secondOperation(pair)); });
            })(firstOperation, secondOperation);
        }
    }

    var isFunction = function (o) {
        return o.formalParameters && o.body;
    }

    var createLet = function (sequential) {
        return function (environment, list) {
            // Evaluate all the expressions and bind the values
            var localEnvironment = createPair({}, environment);
            for (var bindings = list.head; bindings; bindings = bindings.tail) {
                var binding = bindings.head;
                var identifier = parseIdentifier(binding.head);
                if (identifier === null) {
                    throw 'Invalid identifier in let: ' + binding.head;
                }

                var initializeExpression = binding.tail.head;
                if (initializeExpression) {
                    set(localEnvironment, identifier, evaluateInternal(sequential ? localEnvironment : environment, initializeExpression));
                } else {
                    set(localEnvironment, identifier, null);
                }
            }
    
            // Execute the body
            return evaluateSequence(localEnvironment, list.tail);
        };
    };

    // Special forms
    specialForms = {
        quote: function (environment, list) {
            return list.head;
        },

        lambda: function (environment, list) {
            var parameters = list.head;
            var identifiers = [];
            for (var i = 0, parameter = parameters; parameter; parameter = parameter.tail) {
                var identifier = parseIdentifier(parameter.head);
                if (!identifier) {
                    throw 'Invalid identifier: ' + parameter.head;
                }
            
                identifiers[i++] = identifier;
            }
    
            return {
                closingEnvironment: environment,
                formalParameters: identifiers,
                body: list.tail
            };
        },

        define: function (environment, list) {
            var first = list.head;
            if (isList(first)) {
                // Function: (define (name arg1 arg2 ...) exp1 exp2 ...)
                // Translate to: (define name (lambda (arg1 arg2 ...) exp1 exp2 ...))
                if (first.tail === null) {
                    throw 'define: No identifier supplied'
                }
    
                return specialForms.define(environment, createList(first.head, appendList(createList('lambda', first.tail), list.tail)));
            } else {
                // Variable: name
                var identifier = parseIdentifier(list.head);
                if (!identifier) {
                    throw 'define: Invalid identifier: ' + list.head;
                }
    
                set(environment, identifier, evaluateInternal(environment, list.tail.head));
            }
        },

        let: createLet(false),
        'let*': createLet(true),

        cond: function (environment, list) {
            var result;
            for (; list; list = list.tail) {
                var clause = list.head;
                var predicate = clause.head;
                var consequent = clause.tail.head;
                if (predicate === 'else' || evaluateInternal(environment, predicate) === true) {
                    return evaluateInternal(environment, consequent);
                }
            }
            return result;
        },

        'if': function (environment, list) {
            var predicate = list.head;
            var consequent = list.tail.head;
            if (evaluateInternal(environment, predicate) === true) {
                return evaluateInternal(environment, consequent);
            } else {
                var alternative = list.tail.tail.head;
                return evaluateInternal(environment, alternative);
            }
        },

        and: function (environment, list) {
            var result;
            for (; list; list = list.tail) {
                result = evaluateInternal(environment, list.head);
                if (result !== true) {
                    return false;
                }
            }
    
            return result;
        },

        or: function (environment, list) {
            for (; list; list = list.tail) {
                var result = evaluateInternal(environment, list.head);
                if (result !== false) {
                    return result;
                }
            }
    
            return false;
        },

        not: function (environment, list) {
            return evaluateInternal(environment, list.head) === false;
        },

        'set!': function (environment, list) {
            var identifier = parseIdentifier(list.head);
            var environment = lookupEnvironment(environment, identifier);
            if (environment) {
                set(environment, identifier, evaluateInternal(environment, list.tail.head));
            } else {
                throw 'Undefined variable: ' + identifier;
            }
        },

        begin: function (environment, list) { return evaluateSequence(environment, list); },
    };

    var evaluateInternal = function (environment, expression) {
        var result;
        if (expression === null) {
            return null;
        } else {
            if (isList(expression)) {
                // Combination
                var operator = expression.head;
                if (!operator) {
                    throw 'Invalid combination: ()';
                }

                var specialForm;
                if (!isList(operator) && (specialForm = specialForms[operator])) {
                    // Special form
                    return specialForm(environment, expression.tail);
                } else {
                    var f = evaluateInternal(environment, operator);

                    // Evaluate subexpressions
                    var operands = [];
                    for (var operand = expression.tail; operand; operand = operand.tail) {
                        operands.push(evaluateInternal(environment, operand.head));
                    }

                    if (typeof(f) === 'function') {
                        // Built-in function
                        result = f.apply(null, operands);
                    } else if (isFunction(f)) {
                        // Custom function
                        var formalParameters = f.formalParameters;
                        var localEnvironment = createPair({}, f.closingEnvironment);
                        for (var i = 0, count1 = formalParameters.length, count2 = operands.length; i < count1 && i < count2; i++) {
                            set(localEnvironment, formalParameters[i], operands[i]);
                        }

                        // Evaluate each expression in the local environment and return the last value
                        // TODO: Tail recursion?
                        result = evaluateSequence(localEnvironment, f.body);
                    } else {
                        throw 'Non-function used as an operator: ' + f;
                    }
                }
            } else {
                // Literal
                var result = parseFloat(expression);
                if (isNaN(result)) {
                    if (typeof (expression) === 'string' && expression.length >= 1 && expression[0] === '"') {
                        result = expression.slice(1, expression.length - 1);
                    } else {
                        result = lookup(environment, expression);
                        if (result === undefined) {
                            throw 'No variable named: ' + expression;
                        }
                    }
                }
            }
        }

        return result;
    };

    var evaluateSequence = function (environment, list) {
        var result;
        for (; list; list = list.tail) {
            result = evaluateInternal(environment, list.head);
        }
        return result;
    };

    var evaluate = function (environment, input) {
        return evaluateSequence(environment, parse(tokenize(input)));
    };

    var format = function (value) {
        var output;
        if (value === null) {
            output = '()';
        } else if (value.head) {
            output = '(';
            for (; value !== null; value = value.tail) {
                if (value.head === undefined) {
                    return 'Improper list';
                }
                
                output += format(value.head);
                output += value.tail ? ' ' : ')';
            }
        } else if (value === true) {
            output = '#t';
        } else if (value === false) {
            output = '#f';
        } else {
            output = value.toString();
        }
        return output;
    };

    var Interpreter = function () {
        this.environment = createPair({}, defaultEnvironment);
    }

    Interpreter.prototype.evaluate = function (input) {
        return evaluate(this.environment, input);
    };

    Interpreter.prototype.format = format;

    // Exports
    exports.Interpreter = Interpreter;
})(typeof (exports) === 'undefined' ? (JSLisp = {}) : exports);

