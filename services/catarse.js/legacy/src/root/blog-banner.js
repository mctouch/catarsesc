import m from 'mithril';
import _ from 'underscore';
import h from '../h';
import blogVM from '../vms/blog-vm';

const blogBanner = {
    controller: function(args) {
        const posts = m.prop([]),
            error = m.prop(false);

        blogVM.getBlogPosts().then(posts).catch(error);

        return { posts, error };
    },
    view: function(ctrl, args) {
        return m('section.section-large.bg-gray.before-footer[id=\'blog\']',
            m('.w-container',
                [
                    m('.u-text-center',
                        [
                            m('a[href=\'http://blog.trendnotion.com\'][target=\'blank\']',
                                m('img.u-marginbottom-10[alt=\'Icon blog\'][src=\'/assets/icon-blog.png\']')
                            ),
                            m('.fontsize-large.u-marginbottom-60.text-success',
                                m('a.link-hidden-success[href=\'http://blog.trendnotion.com\'][target=\'__blank\']',
                                    'Blog do Catarse'
                                )
                            )
                        ]
                    ),
                    m('.w-row', _.map(ctrl.posts(), post => m('.w-col.w-col-4.col-blog-post',
                        [
                            m(`a.link-hidden.fontweight-semibold.fontsize-base.u-marginbottom-10[href="${post[1][1]}"][target=\'__blank\']`, post[0][1]),
                            m('.fontsize-smaller.fontcolor-secondary.u-margintop-10', m.trust(`${h.strip(post[6][1].substr(0, 130))}...`))
                        ]
                        ))),
                    ctrl.error() ? m('.w-row', m('.w-col.w-col-12.u-text-center', 'Erro ao carregar posts...')) : ''
                ]
            )
        );
    }
};

export default blogBanner;
