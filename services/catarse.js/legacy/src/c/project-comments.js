import m from 'mithril';
import h from '../h';
import projectReport from './project-report';

const projectComments = {
    controller: function() {
        const loadComments = (el, isInitialized) => (el, isInitialized) => {
            if (isInitialized) { return; }
            h.fbParse();
        };

        return { loadComments };
    },
    view: function(ctrl, args) {
        const project = args.project();
        return m('.w-row',
            [
                m('.w-col.w-col-7',
                m(`.fb-comments[data-href="http://www.trendnotion.com:3000/${project.permalink}"][data-num-posts=50][data-width="610"]`, { config: ctrl.loadComments() })
              ),
                m('.w-col.w-col-5', m.component(projectReport))
            ]
          );
    }
};

export default projectComments;
