'use strict';

cd.urlParam = (name, fallBack) => {
  const params = new URLSearchParams(window.location.search);
  return params.get(name) || fallBack;
};
