window.onload = function () {
    setGraphSize();
    addClickEventToNodes();
    setupSvgScrollAndPan();
};

function setGraphSize() {
    let graph = document.getElementsByTagName('svg')[0];
    graph.setAttribute('width', '1500px');
    graph.setAttribute('height', '775px');
}

function addClickEventToNodes() {
    for (let node of document.getElementsByClassName('node')) {
        node.addEventListener('click', onNodeClick, true);
    }
}

async function onNodeClick(event) {
    let node = event.target.parentElement;
    let feat_name = node.firstElementChild.textContent;

    getAndShowFeat(feat_name, node);
}

async function getAndShowFeat(feat_name, selected_node = null) {
    let feat_obj = await getFeat(feat_name);

    if(!feat_obj.success) {
        alert('Failed to retrieve Feat: ' + feat_name);
        return;
    }

    if (!selected_node) {
        selected_node = findNode(feat_name);
    }

    setSelectedNode(selected_node);
    showFeatDetails(feat_obj.feat);
}

function findNode(feat_name) {
    for (let node of document.getElementsByClassName('node')) {
        if (node.children[2].textContent === feat_name) {
            return node;
        }
    }

    return null;
}

function setSelectedNode(selected_node) {
    for (let node of document.getElementsByClassName('selected_node')) {
        node.setAttribute('class', 'node');
    }

    if (selected_node) {
        selected_node.setAttribute('class', 'node selected_node');
    }
}

function onSearchKeyPress(event) {
    if(event.key === "Enter") {
        onSearchClick();
    }
    else if(event.key === "Escape") {
        hideSearchResults();
    }
}

async function onSearchClick() {
    let feat_query = document.getElementById('feat_search').value
    let search_results = await searchFeats(feat_query);

    if(!search_results.success) {
        alert('Failed to retrieve Feats for query: ' + feat_query);
        return;
    }

    showSearchResults(search_results.results);
}

async function searchFeats(feat_name) {
    let feat_resp = await fetch ('feats?name=' + feat_name);
    return await feat_resp.json();
}

function showSearchResults(results) {
    let results_field = document.getElementById('feat_search_list');
    results_field.innerHTML = '';
    results_field.style.removeProperty('display');

    for(let feat of results) {
        results_field.appendChild(createResultListItem(feat));
    }
}

function hideSearchResults() {
    let results_field = document.getElementById('feat_search_list');
    results_field.innerHTML = '';
    results_field.style.setProperty('display', 'none');
}

function createResultListItem(feat_name) {
    let list_entry = document.createElement('li');
    let list_div = document.createElement('div');

    list_entry.setAttribute('class', 'feat_search_result');
    list_entry.setAttribute('onclick', `onResultClick('${escape_str(feat_name)}')`);
    list_entry.appendChild(list_div);
    list_div.appendChild(document.createTextNode(feat_name));

    return list_entry;
}

function escape_str(str) {
    return str.replaceAll("'", '&quot;');
}

function unescape_str(str) {
    return str.replaceAll('&quot;', "'");
}

async function onResultClick(feat_name) {
    let feat_obj = await getFeat(unescape_str(feat_name));

    if(!feat_obj.success) {
        alert('Failed to retrieve Feat: ' + feat_name);
        return;
    }

    showFeatDetails(feat_obj.feat);
}

async function getFeat(feat_name) {
    let feat_resp = await fetch ('feat/' + feat_name);
    return await feat_resp.json();
}

function showFeatDetails(feat) {
    clearSearch();

    document.getElementById('graph-feat').value = feat.name;
    document.getElementById('feat_name').textContent = feat.name;
    document.getElementById('feat_name').href = feat.url;
    document.getElementById('feat_description').textContent = feat.description;
    showPrerequisites(feat.prerequisites);
    showRequisites(feat.requisites);

    toggleFeatFlagVisibility('feat_combat', feat.is_combat);
    toggleFeatFlagVisibility('feat_armor_mastery', feat.is_armor_mastery);
    toggleFeatFlagVisibility('feat_shield_mastery', feat.is_shield_mastery);
    toggleFeatFlagVisibility('feat_weapon_mastery', feat.is_weapon_mastery);

    document.getElementById('submit_button').style.removeProperty('display');
}

function toggleFeatFlagVisibility(flag_field_id, flag) {
    let flag_field = document.getElementById(flag_field_id);
    flag_field.style.display = flag ? 'inline-block' : 'none';
}

function showPrerequisites(prerequisites) {
    let prereq_field = document.getElementById('feat_prerequisites');

    prereq_field.textContent = 'Prerequisites: ';
    prereq_field.style.display = prerequisites.length > 0 ? 'block' : 'none';

    for(let x = 0; x < prerequisites.length; x++) {
        if (prerequisites[x].is_feat) {
            prereq_field.appendChild(createFeatLink(prerequisites[x].text));
        }
        else {
            prereq_field.append(prerequisites[x].text)
        }

        if (x < prerequisites.length - 1) {
            prereq_field.append(', ');
        }
    }
}

function createFeatLink(feat_name) {
    let link = document.createElement('a');
    link.innerText = feat_name;
    link.className = 'feat_link';
    link.addEventListener('click', onFeatClick);

    return link;
}

function onFeatClick(event) {
    let feat_name = event.target.innerHTML;
    getAndShowFeat(feat_name);
}

function showRequisites(requisites) {
    toggleRequisites(true);

    let requisitesDiv = document.getElementById('feat_requisites_div');
    let requisitesList = document.getElementById('feat_requisites_list');

    requisitesDiv.style.display = requisites.length > 0 ? 'block' : 'none';
    requisitesList.innerHTML = '';

    for(let req of requisites) {
        let list_entry = document.createElement('li');
        list_entry.className = 'feat_requisite';
        list_entry.appendChild(createFeatLink(req));
        requisitesList.appendChild(list_entry);
    }
}

function clearSearch() {
    document.getElementById('feat_search').value = '';
    hideSearchResults();
}

function toggleRequisites(forceCollapse = false) {
    let reqsList = document.getElementById('feat_requisites_list');
    let reqsToggle = document.getElementById('feat_requisites_toggle');

    if (reqsList.style.display === 'none' && !forceCollapse) {
        reqsList.style.display = 'block';
        reqsToggle.setAttribute('toggle_indicator', '- ');
    }
    else {
        reqsList.style.display = 'none';
        reqsToggle.setAttribute('toggle_indicator', '+ ');
    }
}

function showModal() {
    let modal = document.getElementById('modal_container');
    modal.style.display = 'block';
}

function toggleZoomDropdown(forceCollapse = false) {
    let zoomToggle = document.getElementById('zoom_value');
    let zoomOptsList = document.getElementById('zoom_opts');

    if (zoomOptsList.style.display === 'none' && !forceCollapse) {
        zoomOptsList.style.display = 'block';
        zoomToggle.setAttribute('class', 'zoom_value_open');
    }
    else {
        zoomOptsList.style.display = 'none';
        zoomToggle.setAttribute('class', 'zoom_value');
    }
}

function getViewBox(svgImage) {
    let curViewBox = svgImage.getAttribute('viewBox').split(' ');
    return {
        x: parseFloat(curViewBox[0]), y: parseFloat(curViewBox[1]),
        w: parseFloat(curViewBox[2]), h: parseFloat(curViewBox[3])
    };
}

function setViewBox(svgImage, viewBox) {
    svgImage.setAttribute('viewBox', `${viewBox.x} ${viewBox.y} ${viewBox.w} ${viewBox.h}`);
}

function getScale(svgImage) {
    return svgImage.clientWidth / getViewBox(svgImage).w;
}

function setZoomString(zoomPercent) {
    let zoomValue = document.getElementById('zoom_value');
    zoomValue.innerText = `${zoomPercent}%`;
}

function incrementZoomLevel(zoomDelta) {
    let svgImage = document.getElementById('graph_div').getElementsByTagName('svg')[0];
    let zoomPercent = getScale(svgImage) * 100;

    setZoomLevel(Math.round(zoomPercent + zoomDelta));
}

function setZoomLevel(zoomPercent) {
    toggleZoomDropdown(true);
    let svgImage = document.getElementById('graph_div').getElementsByTagName('svg')[0];
    let viewBox = getViewBox(svgImage);

    viewBox.w = svgImage.clientWidth / (zoomPercent / 100);
    viewBox.h = svgImage.clientHeight / (zoomPercent / 100);

    setZoomString(zoomPercent);
    setViewBox(svgImage, viewBox);
}

function setupSvgScrollAndPan() {
    const svgContainer = document.getElementById('graph_div');
    const svgImage = svgContainer.getElementsByTagName('svg')[0];

    let viewBox = {
        x: -150, y: -50,
        w: svgImage.clientWidth, h: svgImage.clientHeight
    };
    setViewBox(svgImage, viewBox);

    var isPanning = false;
    var startPoint = { x: 0, y: 0 };
    var endPoint = { x: 0, y: 0 };
    var movingViewBox = { x: 0, y: 0, w: 0, h: 0 }

    svgContainer.onwheel = function(e) {
        e.preventDefault();

        const svgSize = { w:svgImage.clientWidth, h:svgImage.clientHeight };
        let viewBox = getViewBox(svgImage);
        let dw = viewBox.w * Math.sign(e.deltaY) * -0.05;
        let dh = viewBox.h * Math.sign(e.deltaY) * -0.05;
        let dx = dw * e.offsetX / svgSize.w;
        let dy = dh * e.offsetY / svgSize.h;

        viewBox = {
            x: viewBox.x + dx, y: viewBox.y + dy,
            w: viewBox.w - dw, h: viewBox.h - dh
        };

        setZoomString(Math.round((svgSize.w / viewBox.w) * 100));
        setViewBox(svgImage, viewBox);
    }

    svgContainer.onmousedown = function(e){
        isPanning = true;
        startPoint = {x: e.x, y: e.y};
        movingViewBox = getViewBox(svgImage);
    }

    svgContainer.onmousemove = function(e){
        if (isPanning) {
            endPoint = {x: e.x, y: e.y};
            let scale = getScale(svgImage);
            let dx = (startPoint.x - endPoint.x) / scale;
            let dy = (startPoint.y - endPoint.y) / scale;
            let movedViewBox = {
                x: movingViewBox.x + dx, y: movingViewBox.y + dy,
                w: movingViewBox.w, h: movingViewBox.h
            };
            setViewBox(svgImage, movedViewBox);
        }
    }

    svgContainer.onmouseup = function(e){ isPanning = false; }
    svgContainer.onmouseleave = function(e){ isPanning = false; }
}
