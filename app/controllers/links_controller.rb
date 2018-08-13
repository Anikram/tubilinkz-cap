# Main links controller: creates and runs all the links
#
# (c) goodprogrammer.ru
#
class LinksController < ApplicationController
  before_action :authenticate_user!, except: [:open]
  before_action :set_link, only: [:show, :edit, :update, :destroy]
  before_action :set_linkdomain, only: [:create, :open]
  before_action :set_shortlink, only: [:open]

  after_action :verify_authorized, except: [:open, :index]
  after_action :verify_policy_scoped, only: [:index]

  def open
    # increment clicks counter — in an atomic/thread-safe way
    LinkClickedJob.perform_later(@link)
    redirect_to @link.url, status: :moved_permanently
  end

  # GET /links
  # GET /links.json
  def index
    @links = policy_scope(Link)
  end

  # GET /links/1
  # GET /links/1.json
  def show
    authorize @link
  end

  # GET /links/new
  def new
    @link = Link.new

    authorize @link
  end

  # GET /links/1/edit
  def edit
    authorize @link
  end

  # POST /links
  # POST /links.json
  def create
    @link = Link.new(link_params)

    authorize @link

    @link.user = current_user
    @link.domain = @domain

    if @link.save && verify_recaptcha(model: @link)
      # TBD: move to i18n strings
      redirect_to @link, notice: 'Link was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    authorize @link
    if @link.update(link_params)
      # TBD: move to i18n strings
      redirect_to @link, notice: 'Link was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    authorize @link
    @link.destroy
    # TBD: move to i18n strings
    redirect_to links_url, notice: 'Link was successfully destroyed.'
  end

  private

  def set_link
    @link = Link.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:name, :url)
  end

  # Loads Link model according to domain and param[:short_url] option, see routes.rb
  def set_shortlink
    name = params[:short_url]
    @link = Link.where(name: name, domain: @domain).take
  end

  # set Link domain name (for custom domains feature)
  # empty string by default -- meaning current app tubi.ru domain
  # TBD: only tubi.ru domain for now
  def set_linkdomain
    @domain = nil
  end
end
