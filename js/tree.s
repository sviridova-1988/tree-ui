document.addEventListener("DOMContentLoaded", () => {
  const t = document.forms.Tree;
  const fieldset = [].filter.call(
    t.querySelectorAll("fieldset"),
    (element) => element
  );

  // Sync visual class `isChecked` with the `checked` state for all checkboxes.
  const allInputs = t.querySelectorAll('[type="checkbox"]');
  function syncInputClass(input) {
    if (input.checked) input.classList.add('isChecked');
    else input.classList.remove('isChecked');
  }
  for (let i = 0; i < allInputs.length; i++) {
    const input = allInputs[i];
    input.addEventListener('change', function () {
      syncInputClass(this);
    });
    // Initialize visual state according to current checked value
    syncInputClass(input);
  }

  function findParentCheckbox(fieldset) {
    let prev = fieldset.previousElementSibling;
    while (prev) {
      if (prev.classList.contains('field-checkbox')) {
        const input = prev.querySelector('[type="checkbox"]');
        if (input) return input;
      }
      prev = prev.previousElementSibling;
    }
    return null;
  }

  fieldset.forEach((eFieldset) => {
    const parentCheckbox = findParentCheckbox(eFieldset);
      if (parentCheckbox) {
        parentCheckbox.addEventListener('click', function() {
          setAllCheckboxesInTree(eFieldset, this.checked);
        });
      }
    const main = [].filter.call(
      t.querySelectorAll('[type="checkbox"]'),
      (element) => {
        let node = element;
        while (node && node !== t) {
          if (node.nextElementSibling === eFieldset) {
            return true;
          }
          node = node.parentNode;
        }
        return false;
      }
    );
    main.forEach((eMain) => {
      const all = eFieldset.querySelectorAll('[type="checkbox"]');
      eFieldset.onchange = function () {
        const allChecked = eFieldset.querySelectorAll(
          '[type="checkbox"]:checked'
        ).length;
        eMain.checked = allChecked === all.length;
        eMain.indeterminate = allChecked > 0 && allChecked < all.length;
      };
      eMain.onclick = function () {
        // Запустить change события для обновления вложенных fieldsets
        for (let i = 0; i < all.length; i++) {
          all[i].checked = this.checked;
          // Обновить визуальный класс синхронно, на случай если change не сработает мгновенно
          syncInputClass(all[i]);
          all[i].dispatchEvent(new Event('change', { bubbles: true }));
        }
        // Запустить ещё раз change события для бразера на web-kit
        for (let i = 0; i < all.length; i++) {
          all[i].dispatchEvent(new Event('change', { bubbles: true }));
        }
      };
    });
  });

  // Рекурсивно установите все флажки в наборе полей и вложенных наборах полей
  function setAllCheckboxesInTree(fieldset, checked) {
    let child = fieldset.firstElementChild;
    while (child) {
      if (child.tagName === 'DIV' && child.classList.contains('tree-checkboxes__list--wrapper')) {
        // Обработать дочерние элементы прямого флажка оболочки и вложенные наборы полей
        let node = child.firstElementChild;
        while (node) {
          if (node.classList.contains('field-checkbox')) {
            const input = node.querySelector('[type="checkbox"]');
            if (input) {
                input.checked = checked;
                // Обновить визуальный класс синхронно
                syncInputClass(input);
                input.dispatchEvent(new Event('change', { bubbles: true }));
            }
          } else if (node.tagName === 'FIELDSET' && node.classList.contains('tree-checkboxes__list')) {
            // Recursively set nested fieldset
            setAllCheckboxesInTree(node, checked);
          }
          node = node.nextElementSibling;
        }
      }
      child = child.nextElementSibling;
    }
  }
});
