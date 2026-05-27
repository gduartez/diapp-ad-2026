HTMLWidgets.widget({

  name: 'fillBlanks',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {

        // Helper: set inline style with !important (overrides ioslides etc.)
        function setImportant(el, prop, val) {
          el.style.setProperty(prop, val, 'important');
        }

        // --------------- Get questions from R function and all other variables --------

        const quizCloze = x.convCloze;
        const quizAnswers = x.convAnswers;
        const quizOptions = x.convOptions;

        // Get ID from htmlwidget container
        const widgetId = document.getElementById(el.id).id;

        // Get title and description
        const title = x.title;
        const descript = x.descript;

        // Get element options
        const language = x.language;
        const showTipBtn = x.showTipBtn;
        const showSolutionBtn = x.showSolutionBtn;
        const txtSubmitBtn = x.txtSubmitBtn;
        const txtTipBtnShow = x.txtTipBtnShow;
        const txtTipBtnHide = x.txtTipBtnHide;
        const txtSolutionBtnShow = x.txtSolutionBtnShow;
        const txtSolutionBtnHide = x.txtSolutionBtnHide;
        const tipIntro = x.tipIntro;

        // Get few style params
        const centerWidget = x.center;
        const scrollWidget = x.scroll;
        const fontFamily = x.fontFamily;
        const fontSize = x.fontSize;
        const titleFontSize = x.titleFontSize;
        const descriptFontSize = x.descriptFontSize;
        const clozeWidth = x.clozeWidth;
        const clozeHeight = x.clozeHeight;
        const blanksWidth = x.blanksWidth;
        const blanksAlign = x.blanksAlign;
        const titleAlign = x.titleAlign;
        const questionCol = x.questionCol;
        const questionBg = x.questionBg;
        const questionFontSize = descriptFontSize;
        const titleCol = x.titleCol;
        const titleBg = x.titleBg;
        const mainCol = x.mainCol;
        const mainBg = x.mainBg;
        const navBtnBg = x.navBtnBg;
        const navBtnCol = x.navBtnCol;
        const tipBtnBg = x.tipBtnBg;
        const tipBtnHover = x.tipBtnHover;
        const tipBtnCol = x.tipBtnCol;
        const solutionBtnBg = x.solutionBtnBg;
        const solutionBtnHover = x.solutionBtnHover;
        const solutionBtnCol = x.solutionBtnCol;
        const tipAreaCol = x.tipAreaCol;
        const tipAreaBg = x.tipAreaBg;
        const tipAreaBorder = x.tipAreaBorder;
        const solutionAreaCol = x.solutionAreaCol;
        const solutionAreaBg = x.solutionAreaBg;
        const solutionAreaBorder = x.solutionAreaBorder;


        // ------------ Create all HTML elements -----------------------

        var divWidget = document.getElementById(widgetId); // has to be var and not const or let

        // Prevent click events from propagating to slide frameworks (e.g. slidy)
        divWidget.addEventListener('click', function(e) { e.stopPropagation(); });
        divWidget.addEventListener('mousedown', function(e) { e.stopPropagation(); });

        // Modify parent element (the htmlwidget div)
        divWidget.style.borderRadius = "5px";
        if (centerWidget === "true") {
          divWidget.style.marginLeft = "auto";
          divWidget.style.marginRight = "auto";
        }
        if (scrollWidget === "true") {
          divWidget.style.overflowY = "auto";
          divWidget.style.overflowX = "hidden";
        }

        // QUIZ CONTAINER
        const divQuiz = document.createElement("div");
        divQuiz.classList.add("fbq-quiz");
        divQuiz.style.fontFamily = fontFamily;
        divQuiz.style.fontSize = fontSize+'px';
        divWidget.appendChild(divQuiz);

        // TITLE (only created if title is provided)
        if (title !== "NULL") {
          const divHeader = document.createElement("div");
          divHeader.classList.add("fbq-title");
          divHeader.style.backgroundColor = titleBg;
          divHeader.style.padding = fontSize*0.625+'px 20px';

          const pTitle = document.createElement("p");
          pTitle.classList.add("fbq-title-text");
          pTitle.innerHTML = title;
          pTitle.style.color = titleCol;
          pTitle.style.fontFamily = fontFamily;
          pTitle.style.fontSize = titleFontSize+'px';
          pTitle.style.fontWeight = 'bold';
          pTitle.style.margin = '0';
          pTitle.style.textAlign = titleAlign;

          divHeader.appendChild(pTitle);
          divQuiz.appendChild(divHeader);
        }

        // DESCRIPTION CONTAINER (separate from header, like question in singleQuestions)
        if (descript !== "NULL") {
          const divDescript = document.createElement("div");
          divDescript.classList.add("fbq-question");
          divDescript.style.backgroundColor = questionBg;
          divDescript.style.padding = questionFontSize*0.6 + 'px 20px';

          const pDescript = document.createElement("p");
          pDescript.classList.add("fbq-question-text");
          pDescript.innerHTML = descript;
          pDescript.style.color = questionCol;
          pDescript.style.fontFamily = fontFamily;
          pDescript.style.fontSize = descriptFontSize+'px';
          pDescript.style.lineHeight = descriptFontSize*1.25+'px';
          // pDescript.style.fontWeight = 'bold';
          pDescript.style.margin = '0';
          divDescript.appendChild(pDescript);
          divQuiz.appendChild(divDescript);
        }

        // MAIN PART
        const divMain = document.createElement("div");
        divMain.classList.add("fbq-main");
        divMain.style.backgroundColor = mainBg;
        divMain.style.color = mainCol;
        divQuiz.appendChild(divMain);

        // CLOZE PART
        const divCloze = document.createElement("div");
        divCloze.classList.add("fbq-cloze");
        divCloze.innerHTML = quizCloze;
        divCloze.style.width = clozeWidth;
        divCloze.style.fontFamily = fontFamily;
        divCloze.style.fontSize = fontSize+'px';
        divCloze.style.lineHeight = fontSize*2.5+'px';
        if (clozeHeight !== "NULL") {
          divCloze.style.minHeight = clozeHeight;
        }
        divMain.appendChild(divCloze);

        // Auto-size blank fields based on longest answer
        if (blanksWidth === "auto") {
          // Collect all answer texts
          var answerTexts = [];
          if (typeof quizAnswers === 'string') {
            answerTexts.push(quizAnswers);
          } else if (Array.isArray(quizAnswers)) {
            answerTexts = quizAnswers.slice();
          } else if (typeof quizAnswers === 'object' && quizAnswers !== null) {
            answerTexts = Object.values(quizAnswers);
          }
          // Measure text width using a hidden span
          // Detect if cloze uses <pre> (monospace font)
          var hasPre = quizCloze.indexOf('<pre') !== -1;
          var measureSpan = document.createElement('span');
          measureSpan.style.visibility = 'hidden';
          measureSpan.style.position = 'absolute';
          measureSpan.style.whiteSpace = 'nowrap';
          measureSpan.style.fontFamily = fontFamily;
          measureSpan.style.fontFamily = hasPre ? 'monospace' : fontFamily;
          document.body.appendChild(measureSpan);
          var maxWidth = 0;
          answerTexts.forEach(function(txt) {
            measureSpan.textContent = txt;
            var w = measureSpan.offsetWidth;
            if (w > maxWidth) maxWidth = w;
          });
          document.body.removeChild(measureSpan);
          // Add padding (20px each side) for comfortable fit, minimum 50px
          var autoWidth = Math.max(maxWidth + 40, 50) + 'px';
          var inputs = divCloze.querySelectorAll('.fbq-target');
          inputs.forEach(function(inp) {
            inp.style.width = autoWidth;
          });
        }

        // BUTTONS DIV
        const divButtons = document.createElement("div");
        divButtons.classList.add("fbq-buttons");
        divMain.appendChild(divButtons);

        // SUBMIT BUTTON
        const buttonSubmit = document.createElement('button');
        buttonSubmit.classList.add("fbq-button-submit");
        buttonSubmit.classList.add("fbq-button");
        buttonSubmit.setAttribute('tabindex', '0');
        buttonSubmit.textContent = txtSubmitBtn;
        buttonSubmit.style.fontFamily = fontFamily;
        buttonSubmit.style.fontSize = fontSize + 'px';
        setImportant(buttonSubmit, 'color', navBtnCol);
        setImportant(buttonSubmit, 'background-color', navBtnBg);
        setImportant(buttonSubmit, 'background-image', 'none');
        setImportant(buttonSubmit, 'border-color', navBtnBg);
        divButtons.appendChild(buttonSubmit);

        // ADD EVENT LISTENER FOR THE SUBMIT BUTTON TO CHECK THE ANSWERS
        buttonSubmit.addEventListener('click', function () {
          let score = 0;
          let totalQuestions = 0;

          if (typeof quizAnswers === 'string') {
            totalQuestions = 1;
            const userAnswer = document.querySelector(`#${widgetId} .fbq-target[data-accept="1"]`).value;
            if (userAnswer === quizAnswers) {
              score++;
            }
          } else if (Array.isArray(quizAnswers)) {
            totalQuestions = quizAnswers.length;
            quizAnswers.forEach((part, index) => {
              const userAnswer = document.querySelector(`#${widgetId} .fbq-target[data-accept="${index + 1}"]`).value;
              if (userAnswer === part) {
                score++;
              }
            });
          } else if (typeof quizAnswers === 'object' && quizAnswers !== null) {
            totalQuestions = Object.keys(quizAnswers).length;
            const entries = Object.entries(quizAnswers);
            entries.forEach(([key, part], index) => {
              const userAnswer = document.querySelector(`#${widgetId} .fbq-target[data-accept="${index + 1}"]`).value;
              if (userAnswer === part) {
                score++;
              }
            });
          } else {
          }

          // Color the question/description container as feedback
          var questionDiv = divWidget.querySelector('.fbq-question');
          var questionText = questionDiv ? questionDiv.querySelector('.fbq-question-text') : null;
          if (score === totalQuestions) {
            questionDiv.style.backgroundColor = "#46a346";
            if (questionText) questionText.style.color = "white";
          } else {
            questionDiv.style.backgroundColor = "#CB382F";
            if (questionText) questionText.style.color = "white";
            var resultText = x.txtResultWrong.replace("{score}", score).replace("{total}", totalQuestions);
            setTimeout(function() { alert(resultText); }, 150);
          }
        });


        // TIP BUTTON
        if (showTipBtn === "true") {
          const buttonTip = document.createElement('button');
          buttonTip.classList.add("fbq-button-tip");
          buttonTip.classList.add("fbq-button");
          buttonTip.setAttribute('tabindex', '0');
          buttonTip.textContent = txtTipBtnShow;
          // Add user-specific CSS
          buttonTip.style.fontFamily = fontFamily;
          buttonTip.style.fontSize = fontSize + 'px';
          setImportant(buttonTip, 'color', tipBtnCol);
          setImportant(buttonTip, 'background-color', tipBtnBg);
          setImportant(buttonTip, 'background-image', 'none');
          buttonTip.setAttribute('aria-expanded', 'false');
          buttonTip.setAttribute('aria-controls', widgetId + '-tips');
          // Append to divButtons
          divButtons.appendChild(buttonTip);

          const divTips = document.createElement("div");
          divTips.classList.add("fbq-tips");
          divTips.id = widgetId + '-tips';
          // Add user-specific CSS
          divTips.style.color = tipAreaCol;
          divTips.style.backgroundColor = tipAreaBg;
          divTips.style.border = '1px solid ' + tipAreaBorder;
          // Append to divMain
          divMain.appendChild(divTips);

          const pTipsIntro = document.createElement("p");
          pTipsIntro.classList.add("fbq-tips-intro");
          pTipsIntro.textContent = tipIntro;
          // Append to divTips
          divTips.appendChild(pTipsIntro);

          const pTipsOptions = document.createElement("p");
          pTipsOptions.classList.add("fbq-tips-options");
          // Append to divTips
          divTips.appendChild(pTipsOptions);

          // TOGGLE TIPS VISIBILITY
          let tipsVisible = false;

          buttonTip.addEventListener('click', function () {
            tipsVisible = !tipsVisible; // Toggle state
            buttonTip.setAttribute('aria-expanded', tipsVisible ? 'true' : 'false');

            if (tipsVisible) {
              pTipsOptions.innerHTML = quizOptions;
              // Show the tips section and change button text
              divTips.style.display = 'block';
              buttonTip.textContent = txtTipBtnHide;
            } else {
              // Hide the tips section and reset button text
              divTips.style.display = 'none';
              buttonTip.textContent = txtTipBtnShow;
            }
          });

        }


        // SOLUTION BUTTON
        if (showSolutionBtn === "true") {
          const buttonSolution = document.createElement('button');
          buttonSolution.classList.add("fbq-button-solution");
          buttonSolution.classList.add("fbq-button");
          buttonSolution.setAttribute('tabindex', '0');
          buttonSolution.textContent = txtSolutionBtnShow;
          buttonSolution.style.fontFamily = fontFamily;
          buttonSolution.style.fontSize = fontSize + 'px';
          setImportant(buttonSolution, 'color', solutionBtnCol);
          setImportant(buttonSolution, 'background-color', solutionBtnBg);
          setImportant(buttonSolution, 'background-image', 'none');
          buttonSolution.setAttribute('aria-expanded', 'false');
          divButtons.appendChild(buttonSolution);

          let solutionVisible = false;

          buttonSolution.addEventListener('click', function () {
            solutionVisible = !solutionVisible;  // Toggle state
            buttonSolution.setAttribute('aria-expanded', solutionVisible ? 'true' : 'false');

            // If quizAnswers is a string (single answer case)
            if (typeof quizAnswers === 'string') {
              const inputElement = document.querySelector(`#${widgetId} .fbq-target[data-accept="1"]`);

              if (solutionVisible) {
                if (inputElement) {
                  inputElement.value = quizAnswers;  // Set the answer
                }
                buttonSolution.textContent = txtSolutionBtnHide;
              } else {
                if (inputElement) {
                  inputElement.value = "";  // Clear the input
                }
                buttonSolution.textContent = txtSolutionBtnShow;
              }
            }
            // If quizAnswers is an array (multiple answers case)
            else if (Array.isArray(quizAnswers)) {
              quizAnswers.forEach((part, index) => {
                const inputElement = document.querySelector(`#${widgetId} .fbq-target[data-accept="${index + 1}"]`);

                if (solutionVisible) {
                  if (inputElement) {
                    inputElement.value = part;  // Set the correct answer
                  }
                  buttonSolution.textContent = txtSolutionBtnHide;
                } else {
                  if (inputElement) {
                    inputElement.value = "";  // Clear the input
                  }
                  buttonSolution.textContent = txtSolutionBtnShow;
                }
              });
            }
            // If quizAnswers is an object (multiple key-value pairs case)
            else if (typeof quizAnswers === 'object' && quizAnswers !== null) {
              const entries = Object.entries(quizAnswers);
              entries.forEach(([key, part], index) => {
                const inputElement = document.querySelector(`#${widgetId} .fbq-target[data-accept="${index + 1}"]`);

                if (solutionVisible) {
                  if (inputElement) {
                    inputElement.value = part;  // Set the correct answer
                  }
                  buttonSolution.textContent = txtSolutionBtnHide;
                } else {
                  if (inputElement) {
                    inputElement.value = "";  // Clear the input
                  }
                  buttonSolution.textContent = txtSolutionBtnShow;
                }
              });
            }
          });
        }



      // end of renderValue Function
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
